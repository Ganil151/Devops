 Cable is a transmission media used for transmitting a signal. There are three primary types of cables used in transmission:

### 1. Twisted Pair Cable
_Used for Ethernet networks (Cat5e, Cat6)._
*   **Structure**: Pairs of insulated copper wires twisted together to reduce electromagnetic interference (EMI).
*   **Types**: 
    *   **UTP** (Unshielded Twisted Pair): Most common, used in offices/homes.
    *   **STP** (Shielded Twisted Pair): Has a foil shield for high-interference environments.

### 2. Coaxial Cable
_Used for Cable TV and older Ethernet (10Base2)._
*   **Structure**: Central copper conductor, dielectric insulator, metallic shield, and outer jacket.

```mermaid
block-beta
  columns 1
  block:Coax
    Jacket["Outer Jacket (Plastic)"]
    Shield["Braided Shield (Copper)"]
    Insulator["Dielectric Insulator"]
    Core["Inner Conductor (Copper)"]
  end
```

### 3. Fiber-Optic Cable
_Used for high-speed, long-distance backbones._
*   **Structure**: Glass or plastic core that transmits light.
*   **Benefits**: Immune to EMI/RFI, huge bandwidth, very long distances.
*   **Modes**:
    *   **Single-Mode**: Tiny core, laser light, kilometers of range.
    *   **Multi-Mode**: Larger core, LED light, shorter range (within buildings).