# Effective reproduction number (Rt) estimation with or without a renewal process

⚠️ This is a work in progress

## Overview

To evaluate the role of the latent generative process in the estimation of the effective reproduction number (Rt), we are developing a flexible framework (see `EpiAware`) for Rt estimation that allows for the inclusion of different latent infection models (such as a renewal process) and provides a consistent interface for model fitting, posterior checking, and post-processing.

In `pipeline`, we will use `EpiAware` to explore whether the inclusion of a renewal process in the latent generative process improves the estimation of Rt and other situational awareness signals. This exploration is then written as a manuscript for publication (see `manuscript` for work supporting this).

To install `EpiAware`, see installation instructions in the `EpiAware` directory [`README`](EpiAware/README.md).
