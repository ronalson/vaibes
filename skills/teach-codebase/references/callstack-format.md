# Call stack format

Use this for every Trace and every Onboard critical path. Prefer the repo's language for types. TypeScript shown only as a default.

## Skeleton

```txt
trigger
  -> raw input / unknown
  -> boundary parse (reject shape)
  -> canonical domain input
  -> module interface
  -> adapter call(s)
  -> typed result | expected error
  -> projection
  -> response
```

## Hop table

| Hop | In | Out | Errors | Effects |
| --- | --- | --- | --- | --- |
| `POST /orders` handler | HTTP body | `CreateOrderInput` | 400 parse | none |
| `OrderService.create` | `CreateOrderInput` | `Order` | `StockUnavailable` | none |
| `InventoryPort.reserve` | `Sku`, `Qty` | `Reservation` | `OutOfStock` | inventory row lock |
| `OrderRepo.insert` | `Order` | `OrderId` | `UniqueViolation` | INSERT orders |
| `EventBus.publish` | `OrderPlaced` | ack | timeout | outbox / queue |

Every hop names `file:symbol` or is marked **open question**.

## Extra flows when they exist

Sketch these as separate short stacks, not one crowded diagram:

- Failure. Which errors are domain vs infrastructure. Where they are translated. What the caller sees.
- Retry / cancel / idempotency. What is safe to replay. What is not.
- Observability. Span names, metrics, log fields that identify this path.
- Authz. What is checked, where, and what is assumed after the seam.

## Typed sketch

```ts
type CreateOrderInput = { customerId: CustomerId; lines: OrderLine[] }

type CreateOrderError =
  | { type: "StockUnavailable"; sku: Sku }
  | { type: "PaymentUnknown"; paymentId: PaymentId }

function createOrder(
  input: CreateOrderInput,
  ports: { inventory: InventoryPort; orders: OrderRepo; events: EventBus },
): Result<Order, CreateOrderError>
```

Use project types when they exist. Do not invent branded types the code does not have. If the code uses strings, say so.

## Stop rule

You can walk from trigger to last effect without a hand-waved step. If a step is missing, name the gap and stop inventing.
