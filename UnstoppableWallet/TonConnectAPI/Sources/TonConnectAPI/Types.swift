// Generated by swift-openapi-generator, do not modify.
@_spi(Generated) import OpenAPIRuntime
#if os(Linux)
    @preconcurrency import struct Foundation.Data
    @preconcurrency import struct Foundation.Date
    @preconcurrency import struct Foundation.URL
#else
    import struct Foundation.Data
    import struct Foundation.Date
    import struct Foundation.URL
#endif
/// A type that performs HTTP operations defined by the OpenAPI document.
public protocol APIProtocol: Sendable {
    /// - Remark: HTTP `GET /events`.
    /// - Remark: Generated from `#/paths//events/get(events)`.
    func events(_ input: Operations.events.Input) async throws -> Operations.events.Output
    /// - Remark: HTTP `POST /message`.
    /// - Remark: Generated from `#/paths//message/post(message)`.
    func message(_ input: Operations.message.Input) async throws -> Operations.message.Output
}

/// Convenience overloads for operation inputs.
public extension APIProtocol {
    /// - Remark: HTTP `GET /events`.
    /// - Remark: Generated from `#/paths//events/get(events)`.
    func events(query: Operations.events.Input.Query, headers: Operations.events.Input.Headers = .init())
        async throws -> Operations.events.Output
    { try await events(Operations.events.Input(query: query, headers: headers)) }
    /// - Remark: HTTP `POST /message`.
    /// - Remark: Generated from `#/paths//message/post(message)`.
    func message(
        query: Operations.message.Input.Query,
        headers: Operations.message.Input.Headers = .init(),
        body: Operations.message.Input.Body
    ) async throws -> Operations.message.Output {
        try await message(Operations.message.Input(query: query, headers: headers, body: body))
    }
}

/// Server URLs defined in the OpenAPI document.
public enum Servers {
    public static func server1() throws -> Foundation.URL {
        try Foundation.URL(validatingOpenAPIServerURL: "https://bridge.tonapi.io/bridge")
    }
}

/// Types generated from the components section of the OpenAPI document.
public enum Components {
    /// Types generated from the `#/components/schemas` section of the OpenAPI document.
    public enum Schemas {}
    /// Types generated from the `#/components/parameters` section of the OpenAPI document.
    public enum Parameters {
        /// - Remark: Generated from `#/components/parameters/clientIdParameter`.
        public typealias clientIdParameter = [Swift.String]
        /// - Remark: Generated from `#/components/parameters/toParameter`.
        public typealias toParameter = [Swift.String]
    }

    /// Types generated from the `#/components/requestBodies` section of the OpenAPI document.
    public enum RequestBodies {}
    /// Types generated from the `#/components/responses` section of the OpenAPI document.
    public enum Responses {
        public struct Response: Sendable, Hashable {
            /// - Remark: Generated from `#/components/responses/Response/content`.
            @frozen public enum Body: Sendable, Hashable {
                /// - Remark: Generated from `#/components/responses/Response/content/json`.
                public struct jsonPayload: Codable, Hashable, Sendable {
                    /// - Remark: Generated from `#/components/responses/Response/content/json/message`.
                    public var message: Swift.String
                    /// - Remark: Generated from `#/components/responses/Response/content/json/statusCode`.
                    public var statusCode: Swift.Int64
                    /// Creates a new `jsonPayload`.
                    ///
                    /// - Parameters:
                    ///   - message:
                    ///   - statusCode:
                    public init(message: Swift.String, statusCode: Swift.Int64) {
                        self.message = message
                        self.statusCode = statusCode
                    }

                    public enum CodingKeys: String, CodingKey {
                        case message
                        case statusCode
                    }
                }

                /// - Remark: Generated from `#/components/responses/Response/content/application\/json`.
                case json(Components.Responses.Response.Body.jsonPayload)
                /// The associated value of the enum case if `self` is `.json`.
                ///
                /// - Throws: An error if `self` is not `.json`.
                /// - SeeAlso: `.json`.
                public var json: Components.Responses.Response.Body.jsonPayload {
                    get throws {
                        switch self {
                        case let .json(body): return body
                        }
                    }
                }
            }

            /// Received HTTP response body
            public var body: Components.Responses.Response.Body
            /// Creates a new `Response`.
            ///
            /// - Parameters:
            ///   - body: Received HTTP response body
            public init(body: Components.Responses.Response.Body) { self.body = body }
        }
    }

    /// Types generated from the `#/components/headers` section of the OpenAPI document.
    public enum Headers {}
}

/// API operations, with input and output types, generated from `#/paths` in the OpenAPI document.
public enum Operations {
    /// - Remark: HTTP `GET /events`.
    /// - Remark: Generated from `#/paths//events/get(events)`.
    public enum events {
        public static let id: Swift.String = "events"
        public struct Input: Sendable, Hashable {
            /// - Remark: Generated from `#/paths/events/GET/query`.
            public struct Query: Sendable, Hashable {
                /// - Remark: Generated from `#/paths/events/GET/query/client_id`.
                public var client_id: Components.Parameters.clientIdParameter
                /// - Remark: Generated from `#/paths/events/GET/query/last_event_id`.
                public var last_event_id: Swift.String?
                /// Creates a new `Query`.
                ///
                /// - Parameters:
                ///   - client_id:
                ///   - last_event_id:
                public init(client_id: Components.Parameters.clientIdParameter, last_event_id: Swift.String? = nil) {
                    self.client_id = client_id
                    self.last_event_id = last_event_id
                }
            }

            public var query: Operations.events.Input.Query
            /// - Remark: Generated from `#/paths/events/GET/header`.
            public struct Headers: Sendable, Hashable {
                public var accept: [OpenAPIRuntime.AcceptHeaderContentType<Operations.events.AcceptableContentType>]
                /// Creates a new `Headers`.
                ///
                /// - Parameters:
                ///   - accept:
                public init(
                    accept: [OpenAPIRuntime.AcceptHeaderContentType<Operations.events.AcceptableContentType>] =
                        .defaultValues()
                ) { self.accept = accept }
            }

            public var headers: Operations.events.Input.Headers
            /// Creates a new `Input`.
            ///
            /// - Parameters:
            ///   - query:
            ///   - headers:
            public init(query: Operations.events.Input.Query, headers: Operations.events.Input.Headers = .init()) {
                self.query = query
                self.headers = headers
            }
        }

        @frozen public enum Output: Sendable, Hashable {
            public struct Ok: Sendable, Hashable {
                /// - Remark: Generated from `#/paths/events/GET/responses/200/content`.
                @frozen public enum Body: Sendable, Hashable {
                    /// - Remark: Generated from `#/paths/events/GET/responses/200/content/text\/event-stream`.
                    case text_event_hyphen_stream(OpenAPIRuntime.HTTPBody)
                    /// The associated value of the enum case if `self` is `.text_event_hyphen_stream`.
                    ///
                    /// - Throws: An error if `self` is not `.text_event_hyphen_stream`.
                    /// - SeeAlso: `.text_event_hyphen_stream`.
                    public var text_event_hyphen_stream: OpenAPIRuntime.HTTPBody {
                        get throws {
                            switch self {
                            case let .text_event_hyphen_stream(body): return body
                            }
                        }
                    }
                }

                /// Received HTTP response body
                public var body: Operations.events.Output.Ok.Body
                /// Creates a new `Ok`.
                ///
                /// - Parameters:
                ///   - body: Received HTTP response body
                public init(body: Operations.events.Output.Ok.Body) { self.body = body }
            }

            /// OK
            ///
            /// - Remark: Generated from `#/paths//events/get(events)/responses/200`.
            ///
            /// HTTP response code: `200 ok`.
            case ok(Operations.events.Output.Ok)
            /// The associated value of the enum case if `self` is `.ok`.
            ///
            /// - Throws: An error if `self` is not `.ok`.
            /// - SeeAlso: `.ok`.
            public var ok: Operations.events.Output.Ok {
                get throws {
                    switch self {
                    case let .ok(response): return response
                    default: try throwUnexpectedResponseStatus(expectedStatus: "ok", response: self)
                    }
                }
            }

            /// Undocumented response.
            ///
            /// A response with a code that is not documented in the OpenAPI document.
            case undocumented(statusCode: Swift.Int, OpenAPIRuntime.UndocumentedPayload)
        }

        @frozen public enum AcceptableContentType: AcceptableProtocol {
            case text_event_hyphen_stream
            case other(Swift.String)
            public init?(rawValue: Swift.String) {
                switch rawValue.lowercased() {
                case "text/event-stream": self = .text_event_hyphen_stream
                default: self = .other(rawValue)
                }
            }

            public var rawValue: Swift.String {
                switch self {
                case let .other(string): return string
                case .text_event_hyphen_stream: return "text/event-stream"
                }
            }

            public static var allCases: [Self] { [.text_event_hyphen_stream] }
        }
    }

    /// - Remark: HTTP `POST /message`.
    /// - Remark: Generated from `#/paths//message/post(message)`.
    public enum message {
        public static let id: Swift.String = "message"
        public struct Input: Sendable, Hashable {
            /// - Remark: Generated from `#/paths/message/POST/query`.
            public struct Query: Sendable, Hashable {
                /// - Remark: Generated from `#/paths/message/POST/query/client_id`.
                public var client_id: Swift.String
                /// - Remark: Generated from `#/paths/message/POST/query/to`.
                public var to: Swift.String
                /// - Remark: Generated from `#/paths/message/POST/query/ttl`.
                public var ttl: Swift.Int64
                /// Creates a new `Query`.
                ///
                /// - Parameters:
                ///   - client_id:
                ///   - to:
                ///   - ttl:
                public init(client_id: Swift.String, to: Swift.String, ttl: Swift.Int64) {
                    self.client_id = client_id
                    self.to = to
                    self.ttl = ttl
                }
            }

            public var query: Operations.message.Input.Query
            /// - Remark: Generated from `#/paths/message/POST/header`.
            public struct Headers: Sendable, Hashable {
                public var accept: [OpenAPIRuntime.AcceptHeaderContentType<Operations.message.AcceptableContentType>]
                /// Creates a new `Headers`.
                ///
                /// - Parameters:
                ///   - accept:
                public init(
                    accept: [OpenAPIRuntime.AcceptHeaderContentType<Operations.message.AcceptableContentType>] =
                        .defaultValues()
                ) { self.accept = accept }
            }

            public var headers: Operations.message.Input.Headers
            /// - Remark: Generated from `#/paths/message/POST/requestBody`.
            @frozen public enum Body: Sendable, Hashable {
                /// - Remark: Generated from `#/paths/message/POST/requestBody/content/text\/plain`.
                case plainText(OpenAPIRuntime.HTTPBody)
            }

            public var body: Operations.message.Input.Body
            /// Creates a new `Input`.
            ///
            /// - Parameters:
            ///   - query:
            ///   - headers:
            ///   - body:
            public init(
                query: Operations.message.Input.Query,
                headers: Operations.message.Input.Headers = .init(),
                body: Operations.message.Input.Body
            ) {
                self.query = query
                self.headers = headers
                self.body = body
            }
        }

        @frozen public enum Output: Sendable, Hashable {
            /// OK
            ///
            /// - Remark: Generated from `#/paths//message/post(message)/responses/200`.
            ///
            /// HTTP response code: `200 ok`.
            case ok(Components.Responses.Response)
            /// The associated value of the enum case if `self` is `.ok`.
            ///
            /// - Throws: An error if `self` is not `.ok`.
            /// - SeeAlso: `.ok`.
            public var ok: Components.Responses.Response {
                get throws {
                    switch self {
                    case let .ok(response): return response
                    default: try throwUnexpectedResponseStatus(expectedStatus: "ok", response: self)
                    }
                }
            }

            /// OK
            ///
            /// - Remark: Generated from `#/paths//message/post(message)/responses/default`.
            ///
            /// HTTP response code: `default`.
            case `default`(statusCode: Swift.Int, Components.Responses.Response)
            /// The associated value of the enum case if `self` is `.`default``.
            ///
            /// - Throws: An error if `self` is not `.`default``.
            /// - SeeAlso: `.`default``.
            public var `default`: Components.Responses.Response {
                get throws {
                    switch self {
                    case let .default(_, response): return response
                    default: try throwUnexpectedResponseStatus(expectedStatus: "default", response: self)
                    }
                }
            }
        }

        @frozen public enum AcceptableContentType: AcceptableProtocol {
            case json
            case other(Swift.String)
            public init?(rawValue: Swift.String) {
                switch rawValue.lowercased() {
                case "application/json": self = .json
                default: self = .other(rawValue)
                }
            }

            public var rawValue: Swift.String {
                switch self {
                case let .other(string): return string
                case .json: return "application/json"
                }
            }

            public static var allCases: [Self] { [.json] }
        }
    }
}