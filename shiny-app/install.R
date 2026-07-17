# Run once in your Domino compute environment (Dockerfile instructions or
# environment "Pre-Run Script") to ensure required R packages are present.
# For a production migration, prefer renv::restore() with a committed
# renv.lock instead of ad hoc install.packages() calls.

required_packages <- c("shiny", "ggplot2")

installed <- rownames(installed.packages())
missing <- setdiff(required_packages, installed)

if (length(missing) > 0) {
  install.packages(missing, repos = "https://cloud.r-project.org")
}
