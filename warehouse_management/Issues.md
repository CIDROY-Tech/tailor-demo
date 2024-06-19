#  Issues face during development

1. Why am I getting name conflicts for attributes which are under seperate models? 
Enum transactionType has different meaning and implementation in both the model.
```log
cue eval -f manifest/workspace.cue -o generated/workspace.cue
^[[I5 errors in empty disjunction:
Apps: field not allowed:
    ./cue.mod/pkg/github.com/tailor-platform/tailorctl/schema/v2/common/common.cue:34:12
    ./cue.mod/pkg/github.com/tailor-platform/tailorctl/schema/v2/workspace.cue:21:15
    ./cue.mod/pkg/github.com/tailor-platform/tailorctl/schema/v2/workspace.cue:36:9
    ./cue.mod/pkg/github.com/tailor-platform/tailorctl/schema/v2/workspace.cue:38:13
    ./cue.mod/pkg/github.com/tailor-platform/tailorctl/schema/v2/workspace.cue:39:2
    ./cue.mod/pkg/github.com/tailor-platform/tailorctl/schema/v2/workspace.cue:41:2
    ./manifest/workspace.cue:1:1
    ./manifest/workspace.cue:12:1
    ./manifest/workspace.cue:13:5
Types.16.Fields.transactionType.Description: 2 errors in empty disjunction:
Types.16.Fields.transactionType.Description: conflicting values "" and "Transaction type.":
    ./cue.mod/pkg/github.com/tailor-platform/tailorctl/schema/v2/tailordb/tailordb.cue:36:52
    ./cue.mod/pkg/github.com/tailor-platform/tailorctl/schema/v2/tailordb/tailordb.cue:48:25
    ./manifest/services/tailordb/ledger/generalLedger.cue:8:16
    ./manifest/services/tailordb/ledger/generalLedger.cue:25:17
    ./manifest/services/tailordb/tailordb.cue:11:1
    ./manifest/services/tailordb/tailordb.cue:30:10
Types.16.Fields.transactionType.Description: conflicting values "Type of the transaction." and "Transaction type.":
    ./manifest/services/tailordb/ledger/generalLedger.cue:25:17
    ./manifest/services/tailordb/ledger/generalLedgerLineItem.cue:45:17
    ./manifest/services/tailordb/tailordb.cue:11:1
    ./manifest/services/tailordb/tailordb.cue:30:10
UserProfileProviderConfig: 3 errors in empty disjunction:
make: *** [generate] Error 1
```

Attribute name of type float also got conflicted

2. Cue is not detecting the new entities added in the schema. 
```log
cue eval -f manifest/workspace.cue -o generated/workspace.cue
^[[Icue vet  -c ./manifest/workspace.cue
Services.0.Types.17: undefined field: GeneralLedgerLineItem:
    ./manifest/services/tailordb/tailordb.cue:31:17
Tailordbs.0.Types.17: undefined field: GeneralLedgerLineItem:
    ./manifest/services/tailordb/tailordb.cue:31:17
make: *** [apply] Error 1
```
