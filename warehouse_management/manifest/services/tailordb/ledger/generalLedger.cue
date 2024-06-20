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

        
		transactionType: {
			Type:        tailordb.#TypeEnum
			Description: "Transaction type."
			AllowedValues: [
				{ Value: "SALE", Description: "Sale" },
				{ Value: "REFUND", Description: "Refund" },
				{ Value: "CASH_IN", Description: "Cash In" },
				{ Value: "CASH_OUT", Description: "Cash Out" },
				{ Value: "TRANSFER_IN", Description: "Transfer In" },
				{ Value: "TRANSFER_OUT", Description: "Transfer Out" },
				{ Value: "ADJUSTMENT", Description: "Adjustment" },
				{ Value: "PAYMENT", Description: "Payment" },
				{ Value: "RECEIPT", Description: "Receipt" },
				{ Value: "DEPOSIT", Description: "Deposit" },
				{ Value: "WITHDRAWAL", Description: "Withdrawal" },
				{ Value: "TRANSFER", Description: "Transfer" },
				{ Value: "OTHER", Description: "Other" }
			]
		}

		lineItemIDs: {
			Type:        tailordb.#TypeUUID
			Description: "Line item IDs."
			Array:       true
		}

		lineItems: {
			Type:        "GeneralLedgerLineItem"
            Description: "Line items."
            SourceId:    "lineItemIDs"
            Array:       true
        }
        // If you want to have an array of nested objects, you can define it like this.
		purchaseOrders: {
			Type:        tailordb.#TypeNested
			Description: "purchaseOrders"
			Array:       true
            // it's just a reference to the fields defined below.
            // you can directly write the nested fields here.
			Fields:      _purchaseOrderFields
		}

        amount: {
            Type:        tailordb.#TypeFloat
            Hooks: {
                CreateExpr: "0"
                UpdateExpr: "_value.credit - _value.debit"
            }
        }

        credit: {
            Type:        tailordb.#TypeFloat
            Description: "Transaction credit."
            Hooks: {
                CreateExpr: "0"
            }
        }

        debit: {
            Type:        tailordb.#TypeFloat
            Description: "Transaction debit."
            Hooks: {
                CreateExpr: "0"
            }
        }

		related: {
			Type:        tailordb.#TypeNested
			Description: "Related transactions."
			Fields: {[string]:  tailordb.#Field} & {
				salesOrderID: {
					Type:        tailordb.#TypeUUID
					Description: "Unique identifier for the sale transaction."
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

	_purchaseOrderFields: {[string]: tailordb.#Field} & {
		purchaseOrder: {
			Type:        "PurchaseOrder"
			Description: "purchaseOrder"
			SourceId:    "purchaseOrderId"
		}
		purchaseOrderId: {
			Type:           tailordb.#TypeUUID
			Description:    "purchaseOrderId"
			ForeignKey:     true
			ForeignKeyType: "PurchaseOrder"
		}
	}

