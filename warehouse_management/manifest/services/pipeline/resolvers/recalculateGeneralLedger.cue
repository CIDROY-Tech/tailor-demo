package resolvers

import (
    "github.com/tailor-platform/tailorctl/schema/v2/pipeline"
    "tailor.build/template/manifest/services/pipeline:settings"
)


recalculateGeneralLedger: pipeline.#Resolver & {
    Authorization: pipeline.#AuthInsecure
    Name: "recalculateGeneralLedger"
    Description: """
    When a new Line Item is added or manually triggered, we want to recalculate the sum of all ledger line items and store the result in the main transaction object.""",
    Inputs: [
        {
            Name: "input",
            Required: true,
            Type: {
                Name: "RecalculateGeneralLedgerInput",
                Fields: [
                    { Name: "generalLedgerID", Type: pipeline.ID, Required: true }
                ]
            },
        }
    ],
    PostScript: "context.pipeline.recalculateGeneralLedger.result.id"
    Response: { Type: pipeline.ID }
    Pipelines: [
        {
            Name: "fetchGeneralLedgerLineItems"
            Description: "Fetch the general ledger line item details"
            PreScript: "context.args.input.generalLedgerID"
            Invoker: settings.adminInvoker
            Operation: pipeline.#GraphqlOperation & {
                Query: """
                query generalLedgerLineItems($generalLedgerID:ID!) {
                    generalLedgerLineItems(query: { "generaleLedgerID": { eq: $generalLedgerID }} ) 
						collection {
							id
							salesOrderID
							quantity
							product {
								id
								msrp
							}
                    	}
					}
                }"""
            }
            PostScript: """
            {
                "result": args.generalLedgerLineItems,
                "isValid": !!args.generalLedgerLineItems.length
            }
            """
        },
        {
            Name: "recalculateGeneralLedger"
            Description: "Recalculate the general ledger"
			Test: "context.pipeline.fetchGeneralLedgerLineItems.isValid"
            PreScript: """
			{
				"id": context.args.input.generalLedgerID,
				"input": {
					// TODO: understand how we can do a .reduce() in the pipeline
				}
			}
			"""
            Invoker: settings.adminInvoker
            Operation: pipeline.#GraphqlOperation & {
                Query: """
                mutation updateGeneralLedger($id:ID!, $input:GeneralLedgerUpdateInput!) {
                    updateGeneralLedger(id:$id, input:$input) {
                        id
                    }
                }"""
            }
            PostScript: """
            {
                "result": args.updateGeneralLedger,
            }
            """
        }
    ]
}