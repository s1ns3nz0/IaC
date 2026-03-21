# 1. Infrastructure Dependency Pattern
- Infrastructure dependency refers to when a resource's implementation and attributes depend on other resources.
- Using variables and values for reproducibility and evolvability has limitations, since they can only be used within the same module.

# 2. Unidirectional Dependency
- One resource only refers to other resources
- High-level resources depend on other resources or modules
- Low-level resources have high-level resources that depend on them
- For example:
    + Application has IP address '10.0.0.3'
    + Firewall policy allows all traffic to '10.0.0.3'
    + Firewall contains application traffic policies
    + Firewall is the 'High-level resource' and Application is the 'Low-level resource'

### Circular Dependency
- Can't change resources without affecting other resources
- Chicken first? Egg first?
- Predictability and isolation are critical when changing infrastructure

# 3. Dependency Injection
- Unidirectional Dependency provides methods to minimize the effects of changing low-level modules on high-level modules
- It includes Inversion of Control and Dependency Inversion

## 1) Inversion of Control
- When applying unidirectional dependency to infrastructure, high-level resource changes are conducted based on information from low-level resources
    + e.g., Server requests network ID and IPs from network before the network delivers the information
- Inversion of Control is the principle where high-level resources call low-level resources to obtain or reference required attributes
#### Without IoC(Tight Coupling)
```
# Works — but what if you want to switch to SMS?
# You have to dig INSIDE OrderService and change it.
class EmailService:
    def send(self, message):
        print(f"Sending email: {message}")

class OrderService:
    def __init__(self):
        # OrderService CREATES its own dependency
        # It is in full control — but now tightly coupled to EmailService
        self.notifier = EmailService()

    def place_order(self, item):
        print(f"Order placed: {item}")
        self.notifier.send(f"Your order for {item} is confirmed!")

order = OrderService()
order.place_order("keyboard")
```
#### With IoC(Loose Coupling)
```
from abc import ABC, abstractmethod

# ─── Define an interface (the "contract") ─────────────────────
class Notifier(ABC):
    @abstractmethod
    def send(self, message: str):
        pass

# ─── Concrete implementations ─────────────────────────────────
class EmailNotifier(Notifier):
    def send(self, message: str):
        print(f"[Email] {message}")

class SMSNotifier(Notifier):
    def send(self, message: str):
        print(f"[SMS] {message}")

class SlackNotifier(Notifier):
    def send(self, message: str):
        print(f"[Slack] {message}")

# ─── OrderService no longer creates its dependency ────────────
class OrderService:
    def __init__(self, notifier: Notifier):
        # Dependency is INJECTED from outside
        # OrderService has no idea if it's Email, SMS, or Slack
        self.notifier = notifier

    def place_order(self, item: str):
        print(f"Order placed: {item}")
        self.notifier.send(f"Your order for {item} is confirmed!")


# ─── The CALLER decides which notifier to use ─────────────────
order_email = OrderService(notifier=EmailNotifier())
order_email.place_order("keyboard")
# [Email] Your order for keyboard is confirmed!

order_sms = OrderService(notifier=SMSNotifier())
order_sms.place_order("mouse")
# [SMS] Your order for mouse is confirmed!

order_slack = OrderService(notifier=SlackNotifier())
order_slack.place_order("monitor")
# [Slack] Your order for monitor is confirmed!
```

#### What flipped?
```
Without IoC:  OrderService  ──creates──▶  EmailService
                  (controls its own dependency)

With IoC:     Caller  ──injects──▶  OrderService
                  (control moved OUTSIDE OrderService)
```
## 2) Dependency Inversion
- Dependency Inversion uses an abstract interface to manage the dependencies between high-level and low-level resources
- The abstraction layer acts as an interpreter between high-level and low-level resources
- This layer functions as a buffer, isolating high-level modules from changes in low-level modules

### Three Types of Abstraction
+ (Within the module) Resource Attribute Interpolation
+ (Between modules) Module Outputs
+ (Between modules) Infrastructure State

### Example of SW Principle
```
from abc import ABC, abstractmethod

# ─────────────────────────────────────────────────────────────
# STEP 1: Define the ABSTRACTION (the interface)
# Both sides will depend on THIS — not on each other
# ─────────────────────────────────────────────────────────────
class Database(ABC):
    @abstractmethod
    def save(self, data: str):
        pass


# ─────────────────────────────────────────────────────────────
# STEP 2: Low-level modules implement the abstraction
# They depend UPWARD on the interface — not the other way around
# ─────────────────────────────────────────────────────────────
class MySQLDatabase(Database):
    def save(self, data: str):
        print(f"[MySQL] Saving: {data}")

class PostgreSQLDatabase(Database):
    def save(self, data: str):
        print(f"[PostgreSQL] Saving: {data}")

class MongoDatabase(Database):
    def save(self, data: str):
        print(f"[MongoDB] Saving: {data}")

# ─────────────────────────────────────────────────────────────
# STEP 3: High-level module depends ONLY on the abstraction
# It has no idea which database is actually being used
# ─────────────────────────────────────────────────────────────
class UserService:
    def __init__(self, db: Database):   # ← depends on interface, not MySQL
        self.db = db

    def create_user(self, name: str):
        self.db.save(f"user:{name}")

class OrderService:
    def __init__(self, db: Database):   # ← same interface, any db works
        self.db = db

    def create_order(self, item: str):
        self.db.save(f"order:{item}")


# ─────────────────────────────────────────────────────────────
# STEP 4: The caller wires everything together
# This is the only place that knows about concrete classes
# ─────────────────────────────────────────────────────────────
mysql    = MySQLDatabase()
postgres = PostgreSQLDatabase()
mongo    = MongoDatabase()

# Swap databases freely — no changes inside UserService or OrderService
user_svc  = UserService(db=mysql)
order_svc = OrderService(db=postgres)

user_svc.create_user("Alice")
# [MySQL] Saving: user:Alice

order_svc.create_order("keyboard")
# [PostgreSQL] Saving: order:keyboard

# Switch to MongoDB in one line — nothing else changes
user_svc2 = UserService(db=mongo)
user_svc2.create_user("Bob")
# [MongoDB] Saving: user:Bob

# ─────────────────────────────────────────────────────────────`
What Actually "Inverted"?
BEFORE (violation):

  UserService  ──────────────────────────▶  MySQLDatabase
  (high-level)      direct dependency         (low-level)


AFTER (DIP applied):

  UserService  ──▶  «Database interface»  ◀──  MySQLDatabase
  (high-level)        (abstraction)              (low-level)

                       ↑ BOTH point at the interface
                       ↑ The dependency direction INVERTED
                         for the low-level module
```
## 3) Apply Dependency Injection
- Call low-level modules
- Low-level modules outputs metadata of all resources
- Parses only necesary data from metadata
- Creates high-level resources such as a server using parsed attributions
### Terraform Directories
- Please refer to `Dependency Injection_Terraform` directory
```
terraform/
  ├── modules/           ← reusable modules (receive dependencies)
  │     ├── lambda/
  │     ├── eks/
  │     ├── networking/
  │     └── database/
  │
  └── environments/      ← callers that inject environment-specific values
        ├── prod/
        │     ├── main.tf          ← injects prod values
        │     └── terraform.tfvars ← prod dependency values
        ├── staging/
        │     ├── main.tf          ← injects staging values
        │     └── terraform.tfvars ← staging dependency values
        └── dev/
              ├── main.tf          ← injects dev values
              └── terraform.tfvars ← dev dependency values
```

### How the DI Flow Looks End to End
```
terraform.tfvars (environment-specific values)
        │
        │ inject
        ▼
environments/prod/main.tf (orchestrator)
        │
        ├── inject vpc_cidr ──────────────────► module "networking"
        │                                              │
        │                                              │ outputs: vpc_id
        │                                              │         subnet_ids
        │                                              ▼
        ├── inject vpc_id, subnet_ids ──────► module "database"
        │                                              │
        │                                              │ outputs: table_name
        │                                              │         table_arn
        │                                              ▼
        ├── inject vpc_id, subnet_ids ──────► module "lambda"
        │         table_name (from db)                 │
        │         iam_role_arn                         │ outputs: function_arn
        │         memory_size, timeout                 │
        │                                              ▼
        └── inject vpc_id, subnet_ids ──────► module "eks"
                  node_instance_type
                  desired_node_count
                  enable_spot_instances

Each module:
  ✅ receives everything via variables
  ✅ never hardcodes environment-specific values
  ✅ reusable across prod / staging / dev unchanged
```

---

## Key Takeaway
```
modules/     = the "class definition"
               declares what it NEEDS (variables)
               never decides environment-specific values

environments/ = the "dependency injector"
               decides WHAT to inject per environment
               same module → different injected values
               = different behavior per environment
```
# 4. Facade Pattern
## 1) What it is?
- Facade Pattern outputs attributions of resources within modules to inject dependencies
- The Facade Patter provides a single simplified interface to a complex system of subsystems
- The caller doesn't need to know about the internal complexity
- It only talks to the facade, and the facade coordinates everything underneath.
    + Without Facade: Client talks to subsystem A, B, C, D seperately
    + With Facade: Client talks to ONE facade, Facade talks to A, B, C, D internally
## 2) How it works?
- Facade: The single entry point - simplifies access
- Subsystems: The complex internal componenets(they do real work)
- Client: Only talks to the Facade, never to subsystems directly
### Characteristics
- The facade doesn't add new functionality - it just simplifies access
- Subsystems still exist independently - they can be used directly if needed
- The client is decoupled from the internal complexity
- Adding a new step inside the facade requires zero changes in the client
## 3) Software Design Pattern Example
- Adding a new subsystem step (say, a popcorn machine) only requires a change inside the facade — the client never changes.
```
# ─────────────────────────────────────────────────────────────
# SUBSYSTEMS — each is complex on its own
# ─────────────────────────────────────────────────────────────

class Projector:
    def power_on(self):
        print("[Projector] Powering on...")

    def set_input(self, source: str):
        print(f"[Projector] Input set to: {source}")

    def power_off(self):
        print("[Projector] Powering off...")


class SoundSystem:
    def power_on(self):
        print("[Sound] Powering on...")

    def set_volume(self, level: int):
        print(f"[Sound] Volume set to: {level}")

    def set_surround_mode(self, mode: str):
        print(f"[Sound] Surround mode: {mode}")

    def power_off(self):
        print("[Sound] Powering off...")


class StreamingService:
    def connect(self):
        print("[Streaming] Connecting to server...")

    def authenticate(self):
        print("[Streaming] Authenticating user...")

    def play(self, title: str):
        print(f"[Streaming] Playing: {title}")

    def disconnect(self):
        print("[Streaming] Disconnecting...")


class LightingSystem:
    def dim(self, level: int):
        print(f"[Lights] Dimmed to {level}%")

    def full_brightness(self):
        print("[Lights] Full brightness on")


# ─────────────────────────────────────────────────────────────
# WITHOUT FACADE — the client must coordinate everything itself
# ─────────────────────────────────────────────────────────────

projector  = Projector()
sound      = SoundSystem()
streaming  = StreamingService()
lights     = LightingSystem()

# Client has to know the exact order and details of every step ❌
projector.power_on()
projector.set_input("HDMI-1")
sound.power_on()
sound.set_volume(30)
sound.set_surround_mode("Dolby Atmos")
streaming.connect()
streaming.authenticate()
lights.dim(20)
streaming.play("Inception")

# ... and reversing it is just as painful
streaming.disconnect()
sound.power_off()
projector.power_off()
lights.full_brightness()


# ─────────────────────────────────────────────────────────────
# THE FACADE — wraps all that complexity behind two methods
# ─────────────────────────────────────────────────────────────

class HomeTheatreFacade:
    def __init__(self):
        # Facade owns and manages all subsystems internally
        self._projector  = Projector()
        self._sound      = SoundSystem()
        self._streaming  = StreamingService()
        self._lights     = LightingSystem()

    def watch_movie(self, title: str):
        print("── Starting movie night ──────────────────")
        self._lights.dim(20)
        self._projector.power_on()
        self._projector.set_input("HDMI-1")
        self._sound.power_on()
        self._sound.set_volume(30)
        self._sound.set_surround_mode("Dolby Atmos")
        self._streaming.connect()
        self._streaming.authenticate()
        self._streaming.play(title)
        print("─────────────────────────────────────────")

    def end_movie(self):
        print("── Ending movie night ───────────────────")
        self._streaming.disconnect()
        self._sound.power_off()
        self._projector.power_off()
        self._lights.full_brightness()
        print("─────────────────────────────────────────")


# ─────────────────────────────────────────────────────────────
# WITH FACADE — client only calls two simple methods ✅
# ─────────────────────────────────────────────────────────────

theatre = HomeTheatreFacade()

theatre.watch_movie("Inception")
# ── Starting movie night ──────────────────
# [Lights]     Dimmed to 20%
# [Projector]  Powering on...
# [Projector]  Input set to: HDMI-1
# [Sound]      Powering on...
# [Sound]      Volume set to: 30
# [Sound]      Surround mode: Dolby Atmos
# [Streaming]  Connecting to server...
# [Streaming]  Authenticating user...
# [Streaming]  Playing: Inception
# ─────────────────────────────────────────

theatre.end_movie()
# ── Ending movie night ───────────────────
# [Streaming]  Disconnecting...
# [Sound]      Powering off...
# [Projector]  Powering off...
# [Lights]     Full brightness on
# ─────────────────────────────────────────
```
## 4) Terraform Example
- Please refer to `Facade_Terraform` directory
- In Terraform, the Facade Pattern maps to a wrapper module that hides the complexity of multiple sub-modules behind one clean interface. The root (`main.tf`) calls one module with a few simple variables — the facade module internally orchestrates VPC, EC2, RDS, security groups, and everything else.
- Periodically clean up unused fields to minimize field count.
#### Directory Structure
```
project/
├── main.tf                        ← Client — calls only the facade
├── modules/
    └── app_stack/                 ← FACADE module
        ├── main.tf                ← Coordinates all subsystems
        ├── variables.tf
        ├── outputs.tf
        └── subsystems/
            ├── networking/        ← Subsystem A
            │   ├── main.tf
            │   └── variables.tf
            ├── compute/           ← Subsystem B
            │   ├── main.tf
            │   └── variables.tf
            ├── database/          ← Subsystem C
            │   ├── main.tf
            │   └── variables.tf
            └── security/          ← Subsystem D
                ├── main.tf
                └── variables.tf
```
#### Full Parallel Comparison
```
PYTHON                                TERRAFORM
────────────────────────────────────  ──────────────────────────────────────
HomeTheatreFacade.watch_movie()   →   modules/app_stack/main.tf

self._lights.dim(20)              →   module "networking" { ... }
self._projector.power_on()        →   module "security"   { ... }
self._sound.set_surround_mode()   →   module "compute"    { ... }
self._streaming.play(title)       →   module "database"   { ... }

theatre.watch_movie("Inception")  →   module "prod_stack" {
                                        source = "./modules/app_stack"
                                        name   = "prod"
                                      }
```
# 5. Adapter Pattern
## 1) What it is?
- The Facade Pattern is useful when dependency relationships are simple; however, issues occur when modules become complex.
- The Adapter pattern is a structural design pattern that acts as a bridge between two incompatible interfaces.
- Mapping should be used on multiple infrastructure and be reproducable and evolvable
- The Adapter Pattern converts low-level resource metadata to make it compatible with high-level resources.
## 2) How it works?
```
Your Code                    Third-Party Library
─────────────────────        ───────────────────
expects:                     provides:
  .pay(amount, currency)       .create_charge(amount_cents, currency_lower)
  .refund(tx_id, amount)       .create_refund(charge_id, amount_cents)

These two can't talk to each other directly ✗
Different method names, different parameter formats
```
```
Your Code
  │  calls .pay(19.99, "USD")
  ▼
Adapter
  │  translates:
  │    19.99  → 1999  (dollars to cents)
  │    "USD"  → "usd" (uppercase to lowercase)
  │  calls .create_charge(1999, "usd", source)
  ▼
Third-Party Library
  │  does the actual work
  ▼
Adapter
  │  translates response back
  │    {"status": "succeeded"} → True
  ▼
Your Code receives: True
```
## 3) Software Design Pattern Example
```
# Third-party service returns XML
class XMLWeatherService:
    def get_weather(self):
        return "<weather><temp>22</temp><city>Seoul</city></weather>"

# Your app expects a dictionary
class WeatherService:
    def get_weather(self) -> dict:
        raise NotImplementedError

# ── Adapter ───────────────────────────────────────────────
import xml.etree.ElementTree as ET

class XMLWeatherAdapter(WeatherService):
    def __init__(self, xml_service):
        self._service = xml_service

    def get_weather(self) -> dict:
        xml_str = self._service.get_weather()
        root    = ET.fromstring(xml_str)
        return {                            # translate XML → dict ✅
            "temp": root.find("temp").text,
            "city": root.find("city").text
        }

weather = XMLWeatherAdapter(XMLWeatherService())
print(weather.get_weather())   # {"temp": "22", "city": "Seoul"} ✅
```
## 4) Terraform Example
- Please refer to `Adapter_Terraform` directory
- Multi-Cloud Envrionments
```
Your code (environments/prod/main.tf)
always writes the same thing:

  module "storage" {
    bucket_name = "my-bucket"
    versioning  = true
  }

         │
         │  change ONE line (source)
         │
    ┌────┴────┐
    ▼          ▼
s3-adapter   gcs-adapter
(AWS)        (GCP)
```
# 6. Mediator Pattern
## 1) What it is?
- The Mediator pattern introduces a central coordinator that handles all communication between objects — so they never talk to each other directly.
```
Without Mediator:              With Mediator:
─────────────────              ──────────────
A ←──→ B                       A ──→ Mediator ←── B
A ←──→ C                               │
A ←──→ D                        ┌──────┼──────┐
B ←──→ C                        A      B      C
B ←──→ D                               ↑
C ←──→ D                       everyone talks
                                ONLY to Mediator
Everyone knows everyone        Nobody knows anyone
Tightly coupled 💀             Loosely coupled ✅
```
## 2) How it works?
- Every interaction in the Mediator pattern follows exactly two steps — no exceptions:
    + Step 1 — Component notifies the Mediator
    + Step 2 — Mediator decides what to do
## 3) Software Design Pattern Example
### Without Mediator — every object knows every other
```
class Button:
    def __init__(self, textbox, checkbox):
        self.textbox  = textbox   # knows about textbox
        self.checkbox = checkbox  # knows about checkbox

    def click(self):
        self.textbox.clear()      # directly calls textbox
        self.checkbox.uncheck()   # directly calls checkbox

# Button is tightly coupled to BOTH other components
# Add a new component → must change Button
```
### With Mediator — everyone only talks to mediator ───────
- Mediator handles: clear textbox + uncheck checkbox
- Button has no idea what happened ✅
```
class Mediator:
    def __init__(self):
        self.button   = Button(self)    # passes self as mediator
        self.textbox  = Textbox(self)
        self.checkbox = Checkbox(self)

    def notify(self, sender, event):
        # ALL coordination logic lives here
        if sender == "button" and event == "click":
            self.textbox.clear()
            self.checkbox.uncheck()

        elif sender == "checkbox" and event == "check":
            self.textbox.enable()

        elif sender == "checkbox" and event == "uncheck":
            self.textbox.disable()

class Button:
    def __init__(self, mediator):
        self._mediator = mediator   # only knows mediator

    def click(self):
        self._mediator.notify("button", "click")  # just reports ✅
        # doesn't know what happens next

class Textbox:
    def __init__(self, mediator):
        self._mediator = mediator

    def clear(self):
        print("Textbox cleared")

    def enable(self):
        print("Textbox enabled")

    def disable(self):
        print("Textbox disabled")

class Checkbox:
    def __init__(self, mediator):
        self._mediator = mediator

    def check(self):
        self._mediator.notify("checkbox", "check")

    def uncheck(self):
        print("Checkbox unchecked")

# Usage
ui = Mediator()
ui.button.click()
```
### 4) Terraform Example`
- Please refer to `Mediator_Terraform` directory
```
networking    knows: nothing about others   produces: vpc_id, subnet_ids
database      knows: nothing about others   accepts:  vpc_id, subnet_ids
lambda        knows: nothing about others   accepts:  vpc_id, subnet_ids, table_name
eks           knows: nothing about others   accepts:  vpc_id, subnet_ids

root main.tf  knows: ALL modules            wires:    outputs → inputs
(mediator)
```
# 7. Decide What To Use
Pattern selection depends on the complexity of low-level modules and their dependencies:
- Facade Pattern: Use when a single low-level module depends on multiple high-level modules
- Adapter Pattern: Use when low-level modules have dependencies on numerous high-level modules
- Mediator Pattern: Use when complex dependencies exist between multiple modules