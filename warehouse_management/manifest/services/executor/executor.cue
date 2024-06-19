package executor

import (
  "github.com/tailor-platform/tailorctl/schema/v2/executor"
  "github.com/tailor-platform/tailorctl/schema/v2/common"
	"tailor.build/template/environment"
  "tailor.build/template/manifest/services/pipeline:settings"
)

executor.#Spec & {
  Executors: [
    #salesOrderCreated,
    #salesOrderItemCreated,
  ]
}


#salesOrderCreated: executor.#Executor & {
  Name: "ledger-sale-order-created",
  Description: "Ledger event for sales order created",
  Trigger: executor.#TriggerEvent & {
    EventType: "tailordb.type_record.created"
    Condition: common.#Script & {
      Expr: """
            args.NamespaceName == "\(environment.#app.namespace)" && args.TypeName == "SalesOrder"
            """
    }
  }
  Target: executor.#TargetTailorGraphql & {
    AppName: environment.#app.namespace
    Invoker: settings.adminInvoker
    Query: """
      mutation createGeneralLedgerTrx($input: CreateGeneralLedgerTrxInput!) {
        createGeneralLedgerTrx(input: $input)
      }
    """
    Variables: common.#Script & {
      Expr: """
        data = {
          "input": {
            "salesOrderID": args.data.newRecord.id,
          }
        }
      """
      }
  }
}

#salesOrderItemCreated: executor.#Executor & {
  Name: "ledger-sale-order-line-item-created",
  Description: "Ledger event for sales order line item created",
  Trigger: executor.#TriggerEvent & {
    EventType: "tailordb.type_record.created"
    Condition: common.#Script & {
      Expr: """
            args.NamespaceName == "\(environment.#app.namespace)" && args.TypeName == "SalesOrderLineItem"
            """
    }
  }
  Target: executor.#TargetTailorGraphql & {
    AppName: environment.#app.namespace
    Invoker: settings.adminInvoker
    Query: """
      mutation createGeneralLedgerLineItemTrx($input: CreateGeneralLedgerLineItemTrxInput!) {
        createGeneralLedgerLineItemTrx(input: $input)
      }
    """
    Variables: common.#Script & {
      Expr: """
        data = {
          "input": {
            "salesOrderLineItemID": args.data.newRecord.id,
          }
        }
      """
      }
  }
}
