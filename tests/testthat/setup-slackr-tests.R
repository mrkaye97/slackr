setup({
  if (Sys.getenv('ENVIRONMENT') != 'production') {
    slackr_setup(config_file = '.config')
  }
})
