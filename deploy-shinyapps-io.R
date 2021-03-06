## Needs suggests for rsconnect to deploy
install.packages("rsconnect", dependencies = TRUE)
if (!requireNamespace("stringr", quietly = TRUE)) install.packages("stringr")
if (!requireNamespace("cli", quietly = TRUE)) install.packages("cli")
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")

# Needs the following secrets:
# github.com/username/repo -> Settings -> Secrets
# SHINYAPPS_IO_TOKEN
# SHINYAPPS_IO_SECRET


# message(Sys.getenv('GITHUB_REPOSITORY'))
# message(Sys.getenv("GITHUB_REF"))
# message(Sys.getenv("COMMIT_MESSAGE"))

# This function would be used if the Shiny app was a package
# Self install from the branch, then deploy
# install_pkg = function() {
#   cli::cli_h1("Install pkg")
#   path = paste(Sys.getenv('GITHUB_REPOSITORY'), Sys.getenv("GITHUB_REF"), sep = "@")
#   cli::cli_alert_info("Installing {path}")
#   remotes::install_github(path, upgrade = "never")
#   cli::cli_alert_success("{path} installed!")
# }
#

deploy = function(account = "jumpingrivers", server = "shinyapps.io") {
  cli::cli_h1("Deploying app")
  rsconnect::setAccountInfo(name = account,
                            token = Sys.getenv("SHINYAPPS_IO_TOKEN"),
                            secret = Sys.getenv("SHINYAPPS_IO_SECRET"))

  branch_name = stringr::str_match(Sys.getenv('GITHUB_REF'), "^refs/heads/(.*)$")[1, 2]
  repo_name = stringr::str_match(Sys.getenv("GITHUB_REPOSITORY"), ".*/(.*)$")[1, 2]
  appName = if (branch_name %in% c("master", "main")) repo_name
  else paste(repo_name, branch_name, sep = "-")

  cli::cli_alert_info("appName: ", appName)
  rsconnect::deployApp(
    account = account, server = server,
    appDir = ".",
    appName = appName)
  cli::cli_alert_success("{appName} successfully deployed")
}

# Clean up after merging.
# terminate = function(account = "jumpingrivers", server = "shinyapps.io") {
#   msg = Sys.getenv("TRAVIS_COMMIT_MESSAGE")
#   if (stringr::str_detect(msg, "^Merge pull", negate = TRUE)) return(NULL)
#
#   cli::cli_h1("Terminating app")
#   branch = stringr::str_match(msg, "/([^-\\s]*)")[1, 2]
#   slug = stringr::str_match(Sys.getenv('TRAVIS_REPO_SLUG'), "/(.*)")[1, 2]
#
#   appName = paste(slug, branch, sep = '-')
#   rsconnect::terminateApp(appName = appName, account = account, server = server)
#   cli::cli_alert_success("{appName} successfully terminated")
# }
#

# install_pkg()
deploy(account = "jumpingrivers")
#terminate(account = "nationalarchives")

