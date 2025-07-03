# paper\_disease\_misinformation

**Simulation and analysis of disease spread under misinformation dynamics**

## Overview

This repository contains the NetLogo model and Python Jupyter notebooks supporting the paper **"Assessing the impact of misinformation during the spread of infectious diseases"** (2025). It provides:

* **NetLogo model**: Implements an SEIRD (Susceptible–Exposed–Infected–Recovered–Death) framework extended with awareness and misinformation dynamics.
* **Jupyter notebooks**:

  * `analysis.ipynb`: Generates figures and analysis on the effects of awareness decay and misinformation.
  * `umap_analysis.ipynb`: Applies UMAP for dimensionality reduction and clustering of simulation scenarios.

## Repository Structure

```text
paper_disease_misinformation/
├── SEIRD-awareness-unawareness-updated-i_from_0-10000_more_rho_sample.nlogo  # NetLogo model file
├── analysis.ipynb           # Notebook for core analysis and plotting
├── umap_analysis.ipynb      # Notebook for UMAP-based clustering analysis
├── data/                    # Directory for simulation output CSVs
├── requirements.txt         # Python dependencies
└── README.md                # Project documentation (this file)
```

## Requirements

* **NetLogo** (version 6.1.1 or later)
* **Python** 3.8 or higher
* Python packages listed in `requirements.txt`:

  * numpy
  * pandas
  * matplotlib
  * scipy
  * seaborn
  * scikit-learn
  * umap-learn
  * jupyterlab

Install Python dependencies with:

```bash
pip install -r requirements.txt
```

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
