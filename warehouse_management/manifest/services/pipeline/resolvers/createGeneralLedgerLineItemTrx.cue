package resolvers

import (
    "github.com/tailor-platform/tailorctl/schema/v2/pipeline"
    "tailor.build/template/manifest/services/pipeline:settings"
)


createGeneralLedgerLineItemTrx: pipeline.#Resolver & {
    Authorization: pipeline.#AuthInsecure
    Name: "createGeneralLedgerLineItemTrx"
    Description: """
    When a new sales order line item is created, this pipeline will create the respective general ledger transaction line item. After which the general ledger will be recalculated to reflect the new transaction.""",
    Inputs: [
        {
            Name: "input",
            Required: true,
            Type: {
                Name: "CreateGeneralLedgerLineItemTrxInput",
                Fields: [
                    { Name: "salesOrderLineItemID", Type: pipeline.ID, Required: true }
                ]
            },
        }
    ],
    PostScript: "context.pipeline.createGeneralLedgerLineItemTrx.result.id"
    Response: { Type: pipeline.ID }
    Pipelines: [
        {
            Name: "fetchSalesOrderLineItem"
            Description: "Fetch the sales order line item details"
            PreScript: "context.args.input"
            Invoker: settings.adminInvoker
            Operation: pipeline.#GraphqlOperation & {
                Query: """
                query salesOrderLineItem($salesOrderLineItemID:ID!) {
                    salesOrderLineItem(id:$salesOrderLineItemID) {
                        id
						salesOrderID
						quantity
						product {
							id
							msrp
						}
                    }
                }"""
            }
            PostScript: """
            {
                "result": args.salesOrderLineItem,
                "isValid": !isNull(args.salesOrderLineItem)
            }
            """
        },
        {
            Name: "fetchGeneralLedger"
            Description: "Fetch the General Ledger transaction id"
            PreScript: """
            {
                "salesOrderID": context.pipeline.fetchSalesOrderLineItem.result.salesOrderID
            }"""
            Invoker: settings.adminInvoker
            Operation: pipeline.#GraphqlOperation & {
                Query: """
                query fetchGeneralLedger($salesOrderID:ID!) {
                    generalLedgers(query: { "related.salesOrderID": { eq: $salesOrderID }} ) {
                        id
                    }
                }"""
            }
            PostScript: """
            {
                "result": args.generalLedgers.collection[0],
                "isValid": !isNull(args.generalLedgers.collection)
            }
            """
        },
        {
            Name: "createGeneralLedgerLineItemTrx"
            Description: "Create a new general ledger transaction"
            Test: "context.pipeline.fetchSalesOrder.isValid"
            PreScript: """
            {
                "input": {
                    "storeID": context.pipeline.fetchSalesOrder.result.storeID,
					"generalLedgerId": context.pipeline.fetchGeneralLedger.result.id,
                    "description": "Sales Order Line Item",
                    "amount": context.pipeline.fetchSalesOrder.result.product.msrp * context.pipeline.fetchSalesOrder.result.quantity,
                    "creditType": "CREDIT",
                    "related": {
                        "salesOrderID": context.pipeline.fetchSalesOrderLineItem.salesOrderID,
                        "salesOrderLineItemID": context.pipeline.fetchSalesOrderLineItem.id
                    }
                }
            }"""
            Invoker: settings.adminInvoker
            Operation: pipeline.#GraphqlOperation & {
                Query: """
                mutation createGeneralLedgerLineItem($input:GeneralLedgerLineItemCreateInput!) {
                    createGeneralLedgerLineItem(input:$input) {
                        id
                    }
                }"""
            }
            PostScript: """
            {
                "result": args.createGeneralLedgerLineItem,
            }
            """
        },
        {
            Name: "recalculateGeneralLedger"
            Description: "Recalculate the general ledger"
            PreScript: """
            {
                "input": {
                    "generalLedgerID": context.pipeline.fetchGeneralLedger.result.id
                }
            }
            """
            Invoker: settings.adminInvoker
            Operation: pipeline.#GraphqlOperation & {
                Query: """
                mutation recalculateGeneralLedger($input:RecalculateGeneralLedgerInput!) {
                    recalculateGeneralLedger(input:$input) {
                        id
                    }
                }"""
            }
            PostScript: """
            {
                "result": args.recalculateGeneralLedger,
            }
            """
        }
    ]
}