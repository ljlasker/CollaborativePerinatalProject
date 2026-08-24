# Flynn Effect in the Collaborative Perinatal Project (1959--1966)

## Summary

The CPP birth cohorts span 1959--1966, a period during which U.S. IQ scores
were rising (the Flynn effect). Both the Stanford-Binet (administered at age 4)
and WISC (administered at age 7) were normed on fixed reference populations, so
any secular gains should appear as rising mean scores across birth cohorts. The
CPP offers an unusual window into the Flynn effect because (a) it covers a narrow
but informative period, (b) it has large samples per cohort (2,000--9,000
children), and (c) it allows controls for site, race, and SES that are rarely
available in Flynn effect studies.

## Raw Trends

### Stanford-Binet IQ (age 4) by birth year

| Birth Year | Test Year | N     | Mean IQ | SD   |
|------------|-----------|-------|---------|------|
| 1959       | ~1963     | 2,289 | 97.6    | 15.7 |
| 1960       | ~1964     | 4,730 | 96.5    | 15.9 |
| 1961       | ~1965     | 5,606 | 95.9    | 16.6 |
| 1962       | ~1966     | 5,897 | 96.7    | 16.2 |
| 1963       | ~1967     | 6,104 | 96.8    | 16.0 |
| 1964       | ~1968     | 6,492 | 96.8    | 16.4 |
| 1965       | ~1969     | 5,839 | 97.9    | 17.1 |
| 1966       | ~1970     | 1,686 | 103.6   | 19.5 |

### WISC Full Scale IQ (age 7) by birth year

| Birth Year | Test Year | N     | Mean IQ | SD   |
|------------|-----------|-------|---------|------|
| 1959       | ~1966     | 2,364 | 96.6    | 14.9 |
| 1960       | ~1967     | 5,058 | 95.2    | 14.6 |
| 1961       | ~1968     | 6,198 | 94.5    | 15.1 |
| 1962       | ~1969     | 6,633 | 94.9    | 15.0 |
| 1963       | ~1970     | 6,475 | 95.1    | 14.4 |
| 1964       | ~1971     | 6,601 | 95.6    | 14.3 |
| 1965       | ~1972     | 5,574 | 97.1    | 14.9 |
| 1966       | ~1973     | 1,580 | 100.2   | 15.1 |

Naively, both tests show positive trends: SB b = +0.42 IQ points/year (SE 0.04,
p < 0.0001); WISC b = +0.36/year (SE 0.04, p < 0.0001). Over the full
1959--1966 span, that implies roughly +3 IQ points on both tests.

## The Problem: Site-Level Confounding

The CPP's 12 institutions enrolled at different times. Some sites (e.g.,
site 31 and 37, which together contributed 6,404 children) enrolled
**exclusively** in the early years and contributed zero children to the 1966
cohort. Other sites continued enrolling throughout the study. Because sites
differed systematically in racial composition and SES (e.g., some sites were
predominantly Black, others predominantly White), the apparent cohort trend
partly reflects changing site composition rather than a true secular gain.

**Controlling for site eliminates the WISC trend entirely:**

| Model                        | SB b/year | SE   | p        | WISC b/year | SE   | p      |
|------------------------------|-----------|------|----------|-------------|------|--------|
| Unconditional                | +0.418    | 0.04 | < 0.0001 | +0.361      | 0.04 | < 0.0001 |
| + Site FE                    | +0.278    | 0.04 | < 0.0001 | +0.013      | 0.04 | 0.71   |
| + Site FE + Race + SES       | +0.163    | 0.04 | < 0.0001 | -0.121      | 0.04 | 0.0005 |

The WISC trend drops from +0.36/year to +0.01/year (p = 0.71) with site
controls alone. With site + race + SES, it actually turns significantly
negative (-0.12/year). The SB trend is more resilient, falling from +0.42 to
+0.28 (site) to +0.16 (site + race + SES), but this may reflect different
test-level sensitivity to composition effects rather than a true Flynn gain.

## Within-Race Trends (Controlling for Site)

| Group       | SB b/year | SE   | p        | WISC b/year | SE   | p      |
|-------------|-----------|------|----------|-------------|------|--------|
| White       | +0.417    | 0.07 | < 0.0001 | +0.204      | 0.05 | 0.0002 |
| Black       | +0.265    | 0.05 | < 0.0001 | -0.096      | 0.05 | 0.04   |

Among White children (with site controls), both tests show positive trends.
Among Black children, the SB shows a gain but the WISC shows a small *decline*.
The White/Black divergence on the WISC is notable but may reflect
within-race SES composition shifts rather than differential Flynn effects.

## The 1966 Cohort Problem

The 1966 birth cohort is compositionally distinct:

- N = 2,421 (much smaller than other years: 3,500--9,400)
- 58.9% White vs. 45.8% in other years
- Mean SEI = 56.3 vs. 46.4 in other years
- Two sites (31 and 37) stopped contributing entirely by 1966

This disproportionately White, higher-SES 1966 cohort inflates the
apparent gains at the end of the series. The 1966 SB mean (103.6) is
strikingly high, 6+ points above adjacent years.

**Excluding 1966 (1959--1965 only):**

| Outcome      | b/year | SE   | p      |
|--------------|--------|------|--------|
| SB IQ        | +0.160 | 0.04 | 0.0002 |
| WISC FSIQ    | -0.045 | 0.04 | 0.23   |

Without 1966, the WISC trend is flat. The SB retains a modest +0.16/year gain
(~1 IQ point over the 6-year span), which is within the ballpark of published
Flynn effect estimates for this era (~0.3 IQ points/year; Trahan et al., 2014),
but given the sensitivity to specification, this should be interpreted with
caution.

## Interpretation

1. **The raw cohort trends are heavily confounded by site enrollment timing.**
   Different institutions started and stopped enrolling at different times,
   and these institutions served systematically different populations.
   Conditioning on site removes the WISC trend entirely.

2. **The SB retains a modest positive trend (~0.16 IQ points/year) after
   controlling for site, race, and SES.** This could reflect a genuine Flynn
   effect on the SB, which measures somewhat different abilities than the WISC
   and was administered 3 years earlier (at age 4 vs. age 7). Or it could
   reflect residual composition effects not captured by the coarse site + race +
   SEI controls.

3. **The WISC shows no Flynn effect, or even a slight decline, after
   conditioning.** This is puzzling if there were a true secular gain, since
   the WISC was normed in 1949 and should have been increasingly obsolete.
   One possibility: the 1949 WISC norms were already somewhat generous for
   this population, or within-site demographic shifts were anti-correlated
   with the WISC specifically.

4. **The SB and WISC disagreement is itself informative.** If there were a
   true, uniform Flynn effect operating on all tests, both should show
   similar trends after conditioning. The divergence suggests that at least
   one of the apparent trends is an artifact of composition.

5. **Seven years is a very narrow window.** Standard Flynn effect estimates
   are derived from much longer time series (decades). Even at the canonical
   ~3 IQ points/decade, the expected gain over 1959--1966 is only ~2 points,
   which is small relative to the noise introduced by site-level composition
   changes in a convenience sample.

## Within-Family Analysis

The analysis reconstructs live-birth order from raw CPPVAR, clusters standard
errors by mother, and uses actual birth dates rather than enrollment order.

Mother fixed effects remove stable differences between families, including
site, race, and stable SES. They do not separate birth cohort from sibling rank:
later siblings are necessarily born later, so cohort, maternal age, and rank
remain strongly collinear within mothers.

### Estimates

All coefficients below are standard deviations per decade.

| Specification | WISC estimate (SE) | Stanford-Binet estimate (SE) |
|---|---:|---:|
| OLS, unadjusted | +0.247 (0.027) | +0.246 (0.027) |
| OLS + institution FE | +0.015 (0.024) | +0.165 (0.025) |
| OLS + institution FE + race + SEI | -0.074 (0.024) | +0.097 (0.025) |
| Mother FE, unadjusted | +0.192 (0.047) | +0.524 (0.052) |
| **Mother FE + sex + live-birth order** | **+0.074 (0.107)** | **+0.019 (0.121)** |
| Mother FE + sex + study pregnancy order | -0.057 (0.112) | +0.072 (0.126) |

The rank-adjusted 95% intervals are [-0.136, +0.283] SD/decade for WISC and
[-0.217, +0.256] for Stanford-Binet. Both include zero and effects of either
sign. The large unadjusted mother-FE coefficients are therefore not identified
as secular gains; sibling-rank adjustment absorbs them and sharply
widens uncertainty.

### Cousin-pair sensitivity

First-cousin pair differences provide a looser extended-family control. Models
adjust pair differences in sex and live-birth rank and cluster uncertainty by
connected extended family. Because large cousin networks otherwise contribute
many more pair rows, we also give every extended family equal total weight.

| Outcome | Pair weighted | Equal-family weighted | + maternal age | + maternal age, education, and SEI |
|---|---:|---:|---:|---:|
| WISC FSIQ | +0.125 (0.086) | -0.072 (0.091) | -0.092 (0.091) | -0.146 (0.094) |
| Stanford-Binet IQ | +0.330 (0.094) | +0.203 (0.095) | +0.177 (0.096) | +0.102 (0.099) |

The WISC result is not robustly positive under any weighting or adjustment.
The Stanford-Binet association is positive in the simpler specifications but
not distinguishable from zero after maternal-age adjustment, so the cousin
analysis does not support a blanket claim that every unadjusted cohort contrast
is null. It also does not identify a Flynn effect cleanly: cousins differ in
their nuclear-family environments, and pair weighting materially changes the
estimand.

The age-adjusted, equal-family WISC estimate has a 95% interval of [-0.271,
+0.086] SD/decade. Conditional on equal-family weighting, a linear maternal-age
specification, and no residual mother-specific selection after the stated
controls, +0.086 SD/decade is therefore a model-based 95% upper limit. Adding
maternal education and SEI lowers that upper limit to +0.038. Older maternal age
is positively selected on observed SEI and income in these genealogies; if the
residual selection also weakly raises child IQ, the age-adjusted upper-limit
interpretation is conservative. This is not an assumption-free design-based
bound.

## Bottom Line

The raw CPP cohort trend is heavily compositional. Institution controls nearly
eliminate the WISC trend, and adding race and SEI reverses it. Within mothers,
the apparent trend is positive if sibling rank is omitted but becomes small and
imprecise after live-birth rank or study pregnancy order is included.

The conclusion is therefore **no clearly identified NCPP Flynn
effect in the sibling design**. The WISC sibling estimate is +0.074 SD/decade
with a 95% interval from -0.136 to +0.283; the Stanford-Binet sibling estimate
is +0.019 with an interval from -0.217 to +0.256. The cousin WISC result is also
unstable around zero, whereas the cousin Stanford-Binet association is positive.
These data cannot cleanly distinguish secular change from birth-order,
maternal-age, nuclear-family, or other time-varying processes.

Useful extensions are designs with genuinely independent timing variation:
external test-renorming contrasts, repeated testing of the same individuals,
or other cohorts with sibling births spanning larger and less regular intervals.
