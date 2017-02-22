@Library('libpipelines@master') _

hose {
    EMAIL = 'qa'
    MODULE = 'dcos-cli'
    SLACKTEAM = 'stratiopaas'
    REPOSITORY = 'dcos-cli'
    DEVTIMEOUT = 50
    PKGMODULESNAMES = ['dcos-cli']

    DEV = { config ->
        doCompile(config)
    	doPackage(config)
        doDocker(config)
    }
}
