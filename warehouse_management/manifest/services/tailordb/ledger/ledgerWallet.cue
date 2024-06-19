package ledger

import (
    "github.com/tailor-platform/tailorctl/schema/v2/tailordb"
    "tailor.build/template/manifest/services/tailordb:permissions"
)

LedgerWallet: tailordb.#Type & {
    Name:        "LedgerWallet"
    Description: "Ledger Wallet is the Cache of the latest state of the ledger. It is used to speed up the querying of the ledger."
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

        credit: {
            Type:        tailordb.#TypeFloat
            Description: "Total credit in the ledger."
        }

        debit: {
            Type:        tailordb.#TypeFloat
            Description: "Total debit in the ledger."
        }

        balance: {
            Type:        tailordb.#TypeFloat
            Description: "Total balance in the ledger."
            Hooks: {
                CreateExpr: "_value.credit - _value.debit",
                UpdateExpr: "_value.credit - _value.debit",
            }
        }

    }
    TypePermission: permissions.employee
}
