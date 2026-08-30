workspace "Covenant" "C4 model for the Covenant contract management system" {

    model {
        manager = person "Contract Manager" "A user of Covenant who manages contract lifecycle events"

        covenant = softwareSystem "Covenant" "Lets a contract manager create, execute, and search contracts" {
            ui = container "Angular UI" "Single-page application used by contract managers" "Angular, TypeScript"
            api = container "Covenant API" "Exposes contract management operations over HTTPS/JSON" "WolverineFX.Http, .NET"
            store = container "Event store and projections" "Stores contract aggregate event streams and read-model projections" "Marten, PostgreSQL" "Database"
            search = container "Search index" "Read-optimized index for contract search and listing" "OpenSearch" "Database"
            mq = container "Message bus" "Transports commands and domain events between components" "LavinMQ"
        }

        billing = softwareSystem "Billing System" "Consumes contract lifecycle events to trigger billing and renewal workflows" "External"

        manager -> covenant "Manages contracts using" "HTTPS"
        covenant -> billing "Publishes contract lifecycle events to" "AMQP"

        manager -> ui "Uses" "HTTPS"
        ui -> api "Makes API calls to" "HTTPS/JSON"
        api -> store "Reads from and appends events to" "Marten client"
        api -> search "Indexes and queries" "HTTP"
        api -> mq "Publishes and consumes events via" "AMQP"
        mq -> billing "Delivers contract lifecycle events to" "AMQP"
    }

    views {
        systemContext covenant "SystemContext" {
            include *
            autoLayout
        }

        container covenant "Containers" {
            include *
            autoLayout
        }

        styles {
            element "Database" {
                shape cylinder
            }
        }
    }
}
