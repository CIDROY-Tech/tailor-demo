package ledger

import (
    "github.com/tailor-platform/tailorctl/schema/v2/tailordb"
    "tailor.build/template/manifest/services/tailordb:permissions"
)

GeneralLedger: tailordb.#Type & {
    Name:        "GeneralLedger"
    Description: "General Ledger Transaction Model."
    Settings: {
        Aggregation: true
        PublishRecordEvents: true
    }
    Fields: {
        storeID: {
            Type:        tailordb.#TypeUUID
            Description: "Unique identifier for the store."
        }
        store: {
            Type:        "Store"
            Description: "Store model."
            SourceId:    "storeID"
        }

		generalLedgerId: {
			Type:        tailordb.#TypeUUID
			Description: "Unique identifier for the general ledger."
		}

		generalLedger: {
			Type:        "GeneralLedger"
			Description: "General Ledger model."
			SourceId:    "generalLedgerId"
		}

		description: {
			Type:        tailordb.#TypeString
			Description: "Description of the transaction item."
		}

		amount: {
			Type:        tailordb.#TypeFloat
			Description: "Amount of the transaction item."
		}

		creditType: {
			Type:        tailordb.#TypeEnum
			Description: "Type of the transaction."
			AllowedValues: [
				{ Value: "CREDIT", Description: "Credit" },
				{ Value: "DEBIT", Description: "Debit" }
			]
		}

		related: {
			Type:        tailordb.#TypeNested
			Description: "Related transactions."
			Fields: {[string]:  tailordb.#Field} & {
				salesOrderID: {
					Type:        tailordb.#TypeUUID
					Description: "Unique identifier for the sale transaction."
				}
				saleOrderLineItemID: {
					Type:        tailordb.#TypeUUID
					Description: "Unique identifier for the sale transaction line item."
				}
			}
		}

        createdAt: {
            Type: tailordb.#TypeDateTime
            Description: "The time when this record is created"
            Hooks: {
                CreateExpr: "now()"
            }
        }
        
        updatedAt: {
            Type: tailordb.#TypeDateTime
            Description: "The time when this record is updated"
            Hooks: {
                UpdateExpr: "now()"
            }
        }
    }
    TypePermission: permissions.employee
}
