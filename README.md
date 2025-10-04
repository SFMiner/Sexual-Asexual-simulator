# Adapt or Perish: Sexual vs Asexual Reproduction Simulator

An educational real-time evolution simulation that demonstrates the fundamental trade-offs between sexual and asexual reproductive strategies under various environmental pressures.

![Godot 4.5](https://img.shields.io/badge/Godot-4.5-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Overview

This simulation creates two competing populations of organisms - one reproducing sexually (blue dots) and one asexually (red dots). Watch as they adapt to changing environments through natural selection, showcasing key evolutionary principles:

- **Speed vs Adaptability**: Asexual organisms reproduce faster but adapt slower
- **Environmental Sensitivity**: Sexual populations handle variable conditions better
- **Genetic Diversity**: Sexual recombination vs mutation-driven evolution
- **Population Dynamics**: Real-time observation of evolutionary pressures

## Features

### Organism Traits
Each organism has 6 genetic traits (0-100 scale):
- **Temperature Tolerance** - Survival in hot/cold conditions
- **Pathogen Resistance** - Defense against diseases
- **Resource Efficiency** - Food/energy utilization
- **Mobility** - Movement and escape ability
- **Reproduction Speed** - Base reproduction rate modifier
- **Mutation Rate** - Trait change likelihood (asexual only)

### Environmental Pressures
- **Temperature Cycles** - Sine wave patterns with adjustable amplitude/frequency
- **Pathogen Outbreaks** - Random disease events testing resistance
- **Resource Scarcity** - Affects carrying capacity and reproduction
- **Dynamic Selection** - Real-time fitness calculations

### Reproductive Strategies

**Asexual (Red)**
- Reproduction time: 3-6 seconds
- Offspring: Clone with mutations (5-15% chance per trait)
- No mate-finding required
- Fast population growth

**Sexual (Blue)**
- Reproduction time: 10-15 seconds
- Offspring: Genetic recombination of parents
- Requires finding compatible mate
- Better adaptation through genetic shuffling

## Controls

### Simulation Controls
- **Play/Pause** - Start or stop the simulation
- **Reset** - Restart with new population
- **Speed Slider** - Adjust simulation speed (0.1x - 5.0x)

### View Controls
- **Mouse Wheel** - Zoom in/out (0.5x - 10.0x) centered on mouse
- **Middle Mouse + Drag** - Pan around the view
- **Reset View** - Return to 1.0x zoom and center position
- **Left Click** - Select organism to inspect

### Environment Controls
- **Temperature Amplitude** - How much temperature varies
- **Temperature Frequency** - How fast temperature cycles
- **Pathogen Frequency** - How often disease outbreaks occur
- **Resource Abundance** - Available food/energy level

### Scenarios
Pre-configured environmental setups:
- **Balanced** - Standard conditions for comparison
- **Rapid Change** - Fast environmental shifts favor sexual reproduction
- **Stability Test** - Minimal change favors asexual reproduction
- **Catastrophe Recovery** - Tests genetic diversity importance

## UI Features

### Population Graph
Real-time line graph showing population sizes over time:
- Blue line: Sexual population
- Red line: Asexual population
- Auto-scaling for optimal viewing

### Organism Inspector
Click any organism to view detailed information:
- Generation number and age
- Energy level
- Current position
- All genetic traits with progress bars
- Real-time updates (10 times per second)

### Statistics Panel
- Sexual population count
- Asexual population count
- Total population
- Average generation number

### Data Export
Export simulation data to CSV files including:
- Population history over time
- Environmental conditions
- Trait statistics and distributions
- Spatial heatmaps

## Scientific Accuracy

The simulation demonstrates real evolutionary principles:

1. **Two-Fold Cost of Sex**: Sexual reproduction requires finding mates and produces fewer offspring, yet persists in nature
2. **Red Queen Hypothesis**: Constant environmental change favors sexual reproduction's adaptability
3. **Muller's Ratchet**: Asexual populations accumulate deleterious mutations over time
4. **Genetic Recombination**: Sexual reproduction creates novel trait combinations faster than mutation alone

## Installation

### Prerequisites
- Godot 4.5 or later
- Windows OS (primary target)

### Running from Source
1. Clone this repository
2. Open the project in Godot 4.5
3. Press F5 or click "Run Project"

### Building Executable
1. Open project in Godot
2. Project → Export
3. Select "Windows Desktop" preset
4. Export to desired location

## Technical Architecture

### Performance
- Supports 500-2000 organisms at 60 FPS
- Efficient MultiMesh rendering
- Spatial hash for fast proximity queries
- Batched population updates

### Core Systems
- **PopulationManager**: Organism lifecycle and reproduction
- **EnvironmentManager**: Environmental variables and cycles
- **VisualManager**: Rendering with zoom/pan capabilities
- **StatisticsCollector**: Data sampling and export
- **Genetics**: Centralized trait inheritance system

### Data Structures
- **OrganismData**: Pure data class (no Node overhead)
- **SpatialHash**: O(1) proximity queries for mate-finding
- **RingBuffer**: Efficient time-series data storage
- **ObjectPool**: Performance optimization for large populations

## Development

### File Structure
```
EvolutionSimulator/
├── scenes/
│   ├── core/
│   │   └── main.tscn          # Main scene
│   └── ui/
│       └── hud.tscn           # User interface
├── scripts/
│   ├── core/
│   │   ├── genetics.gd        # Trait inheritance system
│   │   ├── organism_data.gd   # Organism data class
│   │   └── main.gd            # Scene controller
│   ├── managers/
│   │   ├── simulation_manager.gd
│   │   ├── population_manager.gd
│   │   ├── environment_manager.gd
│   │   ├── statistics_collector.gd
│   │   └── visual_manager.gd
│   ├── systems/
│   │   └── spatial_hash.gd    # Proximity queries
│   ├── ui/
│   │   ├── hud_controller.gd
│   │   ├── graph_renderer.gd
│   │   └── control_panel.gd
│   └── utils/
│       ├── ring_buffer.gd
│       ├── object_pool.gd
│       ├── organism_inspector.gd
│       └── data_exporter.gd
└── README.md
```

### Code Style
- GDScript with tab indentation
- Class-based architecture
- Signal-driven communication
- Type hints for clarity

## Educational Use

This simulator is ideal for:
- Biology classrooms teaching evolution
- Understanding reproductive strategy trade-offs
- Demonstrating natural selection in real-time
- Exploring genetic diversity concepts
- Student projects on evolutionary biology

## Future Enhancements

Potential additions:
- Additional environmental pressures (predation, habitat fragmentation)
- More complex trait interactions
- Speciation events
- Horizontal gene transfer
- Parasite-host coevolution
- Historical replay functionality

## Credits

Developed as an educational tool to demonstrate evolutionary principles through interactive simulation.

Built with Godot Engine 4.5.

## License

MIT License - Feel free to use for educational purposes.

## Contributing

Contributions welcome! Areas of interest:
- Additional environmental scenarios
- Performance optimizations
- Educational materials/guides
- Data visualization improvements
- Bug fixes and testing

## Support

For issues or questions:
- Open an issue on GitHub
- Check existing documentation
- Review the design document in project files

---

**Note**: This is a simplified model for educational purposes. Real evolution involves many additional factors not represented in this simulation.