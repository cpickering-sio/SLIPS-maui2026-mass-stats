# Project: SLIPS Maui 2026 — Mass Before/After Statistical Simulation

## Overview
This directory contains statistical simulation code for the flange cap mass
before/after analysis component of the SLIPS Maui 2026 deployment paper:
**"Impact of SLIPS Endurance on Glass Underwater Camera Flat-Port"**
(Pickering, Boulais et al., Thode Lab / Coral Engineering Lab, SIO/UCSD).

The goal is to evaluate whether SLIPS (Slippery Liquid-Infused Porous Surfaces)
anti-fouling coatings on glass camera flat-port flanges significantly reduce
biofouling mass accumulation after a 2-week deployment in tropical waters off
Kihei, Maui, Hawaii.

## Experimental Design (from Maui2026Methods_Draft1.pdf)
- **9 total sampling units:**
  - 3 × SLIPS-coated glass flanges
  - 3 × uncoated glass flanges (control)
  - 3 × factory-standard acrylic lens caps (no treatment; coating incompatible)
- **Location:** Shallow sandy-bottom, Kihei, Maui, HI (~6 m / max 20 ft)
- **Duration:** 14-day deployment
- **Substrate masses (measured):**
  - Control glass flanges: ~34.8 g
  - SLIPS-coated glass flanges: ~35.5 g (~0.7 g heavier due to coating)
  - Acrylic caps: ~1.7 g lighter than control glass = ~33.1 g
  - All units measured in **grams**
- **Flange diameter:** 2.2322 in (~56.7 mm), fabricated by Peninsula Glass Co.
- **Housings:** Blue Robotics cylindrical pressure casings

## Mass Measurement Protocol (Section 3.5.3)
- **W1:** Pre-deployment dry mass (fully assembled: O-ring, lens, screws, washers)
- **W2:** Immediately post-retrieval wet mass (includes wet biofilm + sediment)
- **W3:** Post 24-h desiccation dry mass (initial dry mass + accrued dry biomass)
- **ΔW = W3 − W1** (absolute dry biomass gain, g)
- **ΔWr = (W3 − W1) / W1 × 100** (relative gain, %)

## Statistical Analysis (Section 3.7.2)
Decision procedure:
1. Plot ΔW values (histogram, dot plot, Q–Q plot)
2. Run Shapiro–Wilk normality test (low power at n=3; treat as indicative)
3. If no strong skew/outliers → Welch's two-sample t-test
   Otherwise → Mann–Whitney U test
- **α = 0.05**
- **Effect size:** Cohen's d with 95% CI
- Primary comparison: Glass_Control vs. Glass_SLIPS

## Biofouling Context (Tropical Shallow Marine, 14-day) — Literature-Grounded

### Dry Biomass Estimates
- Total external surface area of assembled endcap: ~150 cm²
  (glass insert ~25.3 cm²; full 4" Blue Robotics endcap face + sides)
- **Tropical shallow biofilm at 14 days: 0.05–0.30 mg AFDW/cm²** (organic fraction only)
- **Total dry wt including trapped sediment (sandy bottom): 0.15–1.5 mg/cm²**
- Expected ΔW by treatment:
  - Control glass: **~0.15–0.25 g** (biofilm + sediment, sandy Kihei site)
  - SLIPS glass: **~0.01–0.03 g** (>80% reduction per Karimi et al. 2025)
  - Acrylic: **~0.18–0.28 g** (similar to control; glass accumulates ~15–25% more)

### Dominant Foulers at 2 Weeks (Tropical Shallow, Hawaiian Waters)
1. **Days 0–3:** Conditioning film only (adsorbed proteins, glycoproteins)
2. **Days 3–7:** Bacterial pioneers (*Pseudoalteromonas*, *Vibrio*, *Roseobacter*)
3. **Days 7–14:** Diatom bloom dominant — *Amphora*, *Navicula*, *Nitzschia*, *Cocconeis*
   (brown/golden "slime" visible); protozoan grazers appear
4. **By day 14:** Early recruits possible — *Hydroides* polychaetes (aggressive in tropics),
   barnacle cyprids, bryozoan larvae, *Ulva* sporelings

### Literature Cited
- Chung et al. (2010). *ISME Journal* 4(6):817–828. DOI: 10.1038/ismej.2009.156
  → 0.08 ± 0.03 mg/cm² dry wt on glass at 14 days, tropical Singapore waters
- Callow & Callow (2011). *Nature Communications* 2:244. DOI: 10.1038/ncomms1251
  → 0.05–0.30 mg AFDW/cm² range, warm-water coastal at 2 weeks
- Karimi et al. (2025). *ACS Sustainable Chemistry & Engineering* 13:5808–5817.
  → >80% reduction with SLIPS vs. uncoated controls (in your paper's reference [9])
- Leroy et al. (2008). *Biofouling* 24(1):11–22. DOI: 10.1080/08927010701777108
  → Glass accumulates 15–25% more biofilm than PMMA/acrylic at 14 days
- Molino & Wetherbee (2008). *Biofouling* 24(5):365–379. DOI: 10.1080/08927010802254583
  → Diatom succession in marine biofilms; dominant pennate genera
- Qian et al. (2007). *Marine Biotechnology* 9(4):399–410. DOI: 10.1007/s10126-007-9001-9
  → Biofilm as mediator of macrofouler settlement; bacterial succession
- Chambers et al. (2006). *Surface & Coatings Technology* 201(6):3642–3652.
  DOI: 10.1016/j.surfcoat.2006.08.129 → 70–90% biomass reduction with biocidal coatings
- Wieczorek & Todd (1998). *Biofouling* 12(1–3):81–118. DOI: 10.1080/08927019809378349
  → 0.05–0.15 mg/cm² AFDW at 14 days, tropical Queensland (comparable to Hawaii)
- Godwin (2003). *Biofouling* 19(Supplement):123–131. DOI: 10.1080/0892701031000061750
  → Hawaiian-specific fouling community; *Hydroides*, *Bugula* as early colonizers

**Caveats:** Most gravimetric data are from Indo-Pacific/Australian tropical sites.
Hawaii-specific 14-day gravimetric biofilm data are scarce in the peer-reviewed literature.
Verify all DOIs via Web of Science or Scopus before citing in manuscript.

## Analysis Environment
- **Language:** R (in VS Code)
- **Key packages:** tidyverse, ggplot2, (renv for package management)
- **Main script:** `biofouling_mass_sim.R`

## GitHub Workflow
- Track this directory in a GitHub repository
- Suggested repo structure (see Workflow section below)

## Workflow: GitHub + R in VS Code
1. **Initialize git:** `git init` in this directory (or parent)
2. **Create .gitignore** for R artifacts (`.Rdata`, `.Rhistory`, `renv/library/`)
3. **Install VS Code extensions:** R Extension Pack, GitLens
4. **Use `renv`** for reproducible package management (`renv::init()`)
5. **Push to GitHub:** create repo, set remote, push
6. **Data files:** keep raw data in `data/raw/`, outputs in `outputs/`

## Key Paper Reference Sections
- §3.5.3 Flange Cap Mass Before and After
- §3.7.2 Mass Estimation Statistical Analysis
- Full methods: `/Users/corinnepickering/Desktop/Thode_lab/SLIPS/maui2026/Maui2026Methods_Draft1.pdf`

## Authors / Lab
- Corinne Pickering (corresponding, cpickering@ucsd.edu)
- Océane Boulais — co-first author
- Stefan Koffe, Katherine Wicks (Coral Engineering Lab)
- Daniel Wangpraseurt (SLIPS coatings)
- Aaron Thode (PI, Thode Environmental Acoustics Lab, SIO/UCSD)
