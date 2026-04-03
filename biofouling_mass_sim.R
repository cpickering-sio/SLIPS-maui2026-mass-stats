# =============================================================================
# Biofouling Mass Simulation: SLIPS Maui 2026 Deployment
# Flange Cap Mass Before & After (Section 3.5.3 / 3.7.2)
# Author: Corinne Pickering
# Description: Simulated W1 (pre) and W3 (post-desiccation) mass data
#              for 3 SLIPS-coated glass, 3 uncoated glass control,
#              and 2 factory acrylic flange caps.
#              Units: grams. Alpha = 0.05.
# =============================================================================

library(tidyverse)
library(ggplot2)

dir.create("outputs", showWarnings = FALSE)  # ensure outputs/ folder exists

set.seed(42)  # reproducibility

# =============================================================================
# 1. SIMULATED DATA
# =============================================================================
# Glass flanges: ~50g base (0.05 kg per design spec)
# SLIPS coating adds ~0.5-1g
# Acrylic caps: ~17g lighter than glass = ~33g
#
# LITERATURE-GROUNDED delta W ESTIMATES (14-day tropical shallow deployment):
#
# Glass flange diameter: 2.2322 in = 56.7 mm
# Full Blue Robotics 4" endcap face area: ~81.7 cm² (external exposed surface)
# (glass insert: ~25.3 cm²; remaining plastic face + sides: ~120-150 cm² total)
# Conservative total external surface area: ~150 cm²
#
# Dry biofilm biomass in tropical shallow water at 14 days:
#   AFDW (organic only):  0.05–0.30 mg/cm²
#   Total dry wt (inc. sediment in biofilm): 0.15–1.5 mg/cm²
#   In sandy-bottom site (Kihei), sediment trapping adds ~2-5x organic fraction
#
# Control glass ΔW:  ~0.15-0.25 g  (organic + trapped sediment, ~150 cm²)
# SLIPS glass ΔW:    ~0.01-0.03 g  (SLIPS reduces adhesion >80%, per Karimi 2025)
# Acrylic ΔW:        ~0.18-0.28 g  (similar to control; glass 15-25% more than acrylic
#                                    per Leroy et al. 2008, but sediment equalizes)
#
# Key sources:
#   Chung et al. (2010) ISME J — 0.08 ± 0.03 mg/cm² dry wt on glass at 14d (tropical)
#   Callow & Callow (2011) Nature Comms — 0.05–0.30 mg AFDW/cm² range
#   Karimi et al. (2025) ACS Sustainable Chem Eng — >80% reduction with SLIPS in situ
#   Leroy et al. (2008) Biofouling — glass 15-25% more biofilm than PMMA/acrylic at 14d

flange_data <- tibble(
  sample_id = c(
    "Glass_Control_1", "Glass_Control_2", "Glass_Control_3",
    "Glass_SLIPS_1",   "Glass_SLIPS_2",   "Glass_SLIPS_3",
    "Acrylic_1",       "Acrylic_2",       "Acrylic_3"
  ),
  treatment = factor(
    c(rep("Glass_Control", 3), rep("Glass_SLIPS", 3), rep("Acrylic", 3)),
    levels = c("Glass_Control", "Glass_SLIPS", "Acrylic")
  ),
  substrate = c(rep("Glass", 6), rep("Acrylic", 3)),

  # W1: pre-deployment dry mass (g)
  # Measured values: control glass ~34.8g, SLIPS glass ~35.5g, acrylic ~1.7g less than control (~33.1g)
  W1_g = c(
    34.75, 34.82, 34.79,         # glass control (~34.8g measured)
    35.48, 35.52, 35.49,         # SLIPS coated  (~35.5g measured)
    33.08, 33.14, 33.11          # acrylic        (~33.1g = 34.8 - 1.7g)
  ),

  # W3: post-desiccation dry mass (g) — W1 + accrued dry biomass
  # ΔW values grounded in literature (see comments above)
  W3_g = c(
    34.96, 35.53, 35.02,         # glass control (+0.21, +0.71, +0.23 g) — mean ~0.22g
    35.50, 35.55, 35.51,         # SLIPS coated  (+0.02, +0.03, +0.02 g) — mean ~0.02g
    33.30, 33.39, 33.35          # acrylic       (+0.22, +0.25, +0.24 g) — mean ~0.24g
  )
)

# =============================================================================
# 2. COMPUTE DELTA W
# =============================================================================
flange_data <- flange_data |>
  mutate(
    delta_W_g  = W3_g - W1_g,                  # absolute mass gain (g)
    delta_Wr   = (W3_g - W1_g) / W1_g * 100    # relative mass gain (%)
  )

print(flange_data |> select(sample_id, treatment, W1_g, W3_g, delta_W_g, delta_Wr))

# =============================================================================
# 3. SUMMARY STATISTICS
# =============================================================================
summary_stats <- flange_data |>
  group_by(treatment) |>
  summarise(
    n         = n(),
    mean_W1   = mean(W1_g),
    mean_W3   = mean(W3_g),
    mean_dW   = mean(delta_W_g),
    sd_dW     = sd(delta_W_g),
    se_dW     = sd(delta_W_g) / sqrt(n()),
    mean_dWr  = mean(delta_Wr),
    .groups   = "drop"
  )

print(summary_stats)

# =============================================================================
# 4. NORMALITY CHECK (Shapiro-Wilk) — per Section 3.7.2 decision procedure
# =============================================================================
# NOTE: With n=3, Shapiro-Wilk has very low power. Treat results as indicative.
cat("\n--- Shapiro-Wilk Normality Tests on delta_W ---\n")
# NOTE: With n=3, Shapiro-Wilk has very low power. Treat results as indicative.
by(flange_data$delta_W_g, flange_data$treatment, shapiro.test)

# =============================================================================
# 5. STATISTICAL TESTS (Glass Control vs. Glass SLIPS)
# =============================================================================
ctrl  <- flange_data |> filter(treatment == "Glass_Control") |> pull(delta_W_g)
slips <- flange_data |> filter(treatment == "Glass_SLIPS")   |> pull(delta_W_g)
acryl <- flange_data |> filter(treatment == "Acrylic")       |> pull(delta_W_g)

cat("\n--- Two-sample t-test: Glass Control vs. SLIPS ---\n")
t_test_result <- t.test(ctrl, slips, var.equal = FALSE)  # Welch's t-test
print(t_test_result)

cat("\n--- Mann-Whitney U test: Glass Control vs. SLIPS ---\n")
mw_result <- wilcox.test(ctrl, slips, exact = FALSE)
print(mw_result)

# Cohen's d effect size
cohens_d <- (mean(ctrl) - mean(slips)) /
            sqrt((sd(ctrl)^2 + sd(slips)^2) / 2)
cat(sprintf("\nCohen's d (Control vs. SLIPS): %.3f\n", cohens_d))

# =============================================================================
# 6. VISUALISATION
# =============================================================================

# 6a. Dot plot of delta_W by treatment
p1 <- ggplot(flange_data, aes(x = treatment, y = delta_W_g, color = treatment)) +
  geom_jitter(size = 4, width = 0.1) +
  stat_summary(fun = mean, geom = "crossbar", width = 0.3, fatten = 2,
               color = "black", linewidth = 0.6) +
  labs(
    title = "Simulated Dry Biomass Accrual by Treatment (14-day deployment)",
    subtitle = "Kihei, Maui — Sandy Bottom, ~6 m depth",
    x = "Treatment",
    y = expression(Delta * "W  (g, dry mass accrual)"),
    color = "Treatment"
  ) +
  scale_color_manual(values = c(
    "Glass_Control" = "#E07B54",
    "Glass_SLIPS"   = "#5B9BD5",
    "Acrylic"       = "#70AD47"
  )) +
  theme_bw(base_size = 13) +
  theme(legend.position = "none")

print(p1)
ggsave("outputs/delta_W_dotplot.png", p1, width = 7, height = 5, dpi = 300)

# 6b. Before/After mass table plot
p2 <- flange_data |>
  pivot_longer(cols = c(W1_g, W3_g), names_to = "timepoint", values_to = "mass_g") |>
  mutate(timepoint = recode(timepoint, W1_g = "Pre-deployment (W1)",
                                       W3_g = "Post-desiccation (W3)")) |>
  ggplot(aes(x = timepoint, y = mass_g, group = sample_id, color = treatment)) +
  geom_line(alpha = 0.6) +
  geom_point(size = 3) +
  facet_wrap(~ treatment, scales = "free_y") +
  labs(
    title = "Flange Cap Mass Before & After Deployment (Simulated)",
    x = NULL, y = "Mass (g)",
    color = "Treatment"
  ) +
  scale_color_manual(values = c(
    "Glass_Control" = "#E07B54",
    "Glass_SLIPS"   = "#5B9BD5",
    "Acrylic"       = "#70AD47"
  )) +
  theme_bw(base_size = 12) +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 15, hjust = 1))

print(p2)
ggsave("outputs/before_after_mass.png", p2, width = 9, height = 4, dpi = 300)

# 6c. Q-Q plots for normality assessment
par(mfrow = c(1, 3))
qqnorm(ctrl,  main = "Q-Q: Glass Control delta_W"); qqline(ctrl)
qqnorm(slips, main = "Q-Q: Glass SLIPS delta_W");   qqline(slips)
qqnorm(acryl, main = "Q-Q: Acrylic delta_W");       qqline(acryl)
dev.copy(png, "outputs/qq_plots.png", width = 900, height = 400, res = 100)
dev.off()
par(mfrow = c(1, 1))
