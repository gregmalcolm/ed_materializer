== ED Materializer

Just a prototype backend api for EDDiscovery. It likely not long for this world.

= Setup

1) Install Ruby 2.3

2) Install Postgres

3) Create a role for postgres:
`createuser -r ed_materializer`

4) Run this to setup:
`bundle`
`rake db:create`
`rake db:migrate`