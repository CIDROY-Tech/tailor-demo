package resolvers

import (
    "github.com/tailor-platform/tailorctl/schema/v2/pipeline"
    "tailor.build/template/manifest/services/pipeline:settings"
)


createGeneralLedgerTrx: pipeline.#Resolver & {
    Authorization: pipeline.#AuthInsecure
    Name: "createGeneralLedgerTrx"
    Description: """
    Automatically create a new general ledger transaction when a new sale occurs""",
    Inputs: [
        {
            Name: "input",
            Required: true,
            Type: {
                Name: "CreateGeneralLedgerTrxInput",
                Fields: [
                    { Name: "salesOrderID", Type: pipeline.ID, Required: true }
                ]
            },
        }
    ],
    PostScript: "context.pipeline.createGeneralLedgerTrx.result.id"
    Response: { Type: pipeline.ID }
    Pipelines: [
        {
            Name: "fetchSalesOrder"
            Description: "Fetch the sales order details"
            PreScript: "context.args.input"
            Invoker: settings.adminInvoker
            Operation: pipeline.#GraphqlOperation & {
                Query: """
                query salesOrder($salesOrderID:ID!) {
                    salesOrder(id:$salesOrderID) {
                        storeID
                        salesOrderDate
                        id
                    }
                }"""
            }
            PostScript: """
            {
                "result": args.salesOrder,
                "isValid": !isNull(args.salesOrder)
            }
            """
        },
        {
            Name: "createGeneralLedgerTrx"
            Description: "Create a new general ledger transaction"
            Test: "context.pipeline.fetchSalesOrder.isValid"
            PreScript: """
            {
                "input": {
                    "storeID": context.pipeline.fetchSalesOrder.result.storeID,
                    "transactionDate": context.pipeline.fetchSalesOrder.result.salesOrderDate,
                    "transactionType": "SALES",
                    "related": {
                        "salesOrderID": context.args.input.salesOrderID
                    }
                }
            }
            """
            Invoker: settings.adminInvoker
            Operation: pipeline.#GraphqlOperation & {
                Query: """
                mutation createGeneralLedger($input:GeneralLedgerCreateInput!) {
                    createGeneralLedger(input:$input) {
                        id
                        storeID
                        transactionDate
                        transactionType
                        related {
                            salesOrderID
                        }
                    }
                }"""
            }
            PostScript: """
            {
                "result": args.createGeneralLedger,
            }
            """
        }
    ]
}