
# Designator Resolution

Designator types are defined in the _internal-structure_ module.

They stand in place of other objects, for example we can use a
**string** naming a **package** object in place of the **package**
object itself.

Here we define functions to turn designators into the objects they
designate:

- **resolve-string-designator** → **string**

- **resolve-package-designator** → **package**

- **resolve-home-designator** → **package** or **nil**
