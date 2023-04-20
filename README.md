# Deploy this template:
To deploy this template, you need tailorctl and Tailor account.
If you don’t have a Tailor account, please contact us.

In tailorctl, please run this command to deploy the template.

``` bash
## example tutorial/todo-app
tailorctl template get -t git+https://github.com/tailor-platform/templates@tutorial/todo-app -o charts
```

Once you run this command, this TODO application is deployed to your preserved domain and the GraphQL endpoint will be ready to interact with Frontend.
