# Valkyrie

![Valkyrie](https://upload.wikimedia.org/wikipedia/commons/4/4e/Valkyrie_%281834-1835%29_by_H._W._Bissen.jpg)

> A valkyrie (from Old Norse: valkyrja, lit. 'chooser of the slain'), is one of a host of female figures who guide souls of the dead to the god Odin's hall Valhalla.

Valkyrie is the Arcadia salesforce net zero cloud solution. Its a stand alone application/plugin that customers can install in their salesforce cloud. It has an inbuilt connect ui as a canvas app, through which customers can connect their utillity accounts by entering the credentials for their energy supplier. The connector then uses utility cloud API to fetch the data into odin. The SF scheduler will sync the data into NZC. [This notion page](https://www.notion.so/approduct/Connector-Architecture-Flow-Diagrams-05d857675cc74260835fb201da374c44) describes the architecture and the different flows.

## Packaging

Keep any components needed only by Developers that will not be packaged in the `unpackaged` directory. DX scratch orgs will get all of the metadata under `force-app/`, including `force-app/unpackaged`. When it comes time to deploy to the golden packaging org, only metadata from `force-app/main/` will be converted to legacy metadata and deployed.

## Scratch Org Setup

This project has a dependency on Net Zero Cloud which is enabled in scratch orgs with the feature "SustainabilityApp"

After creating a scratch org using either `dx-utils/setup_scratch_org.sh` or manuall with sfdx commands you must
then push the Industry Settings in the `settings-md` folder using the following command

```shell
sfdx force:mdapi:deploy -d settings-md/ -w 5 -u <scratch-org-alias>
```

This will enable all Net Zero Cloud Settings required

## Installing Canvas App

For development purposes you can install the Urjanet Connect connected app in your org by running the
following command (update the canvas package version, if necessary)

```shell
sfdx force:package:install -p CanvasPackageDevelopment@1.0.0-1 -u <your-org-alias>
```

## dx-utils

All of the scripts in `dx-utils` are meant to be generic, and usable across projects. Utilize the `config/dx-utils.cfg` file to make changes to the following:

-   Name of Unmanaged Package in Salesforce orgs (when using metadata deploy to Int/QA/Packaging orgs)
-   Default Duration of Scratch Orgs
-   Permission Set assignments
-   Managed Packages to install before code push (such as Health Cloud)
-   Creating new users
-   Page to open after a Scratch Org creation command

## Developer Setup

### Install Prettier and Husky pre-commit hook

Run `npm install` to install Husky (for git commit hooks) which will run Prettier on your code when you commit your files to a predetermined CodeScience standard.

**BUGFIX?** If you are experiencing an issue with running Prettier on Apex files, make sure that your JAVA_HOME environment variable is at least running JDK 11 or higher. (Run `java --version` from a command prompt to see your current version.) `prettier-plugin-apex@1.9.0` dropped support for anything below Java 11 ([GitHub Issue](https://github.com/dangmai/prettier-plugin-apex/issues/357)). If you still need Java 8 to be your primary JDK, then change the value in package.json to `"prettier-plugin-apex": "1.8.0"` instead of `"^1.9.0"`, however this might cause some dependencies to be stale or insecure in the future.

### Create Feature Branches With An Org

If you want to follow the pattern of creating a Feature Branch and a fresh Scratch Org with that branch name:

`npm run branch:create BranchName`

Creation commands can have an optional second parameter of scratch org duration. The default is 15 (up from the sfdx default of 7) but you can set this number as high as 30. `npm run branch:create BranchName 30`

This command:

-   creates a new branch and pushes it to origin
-   creates a new scratch org aliased to branch name
-   pushes the dx metadata to scratch org
-   assigns the required permission set to your user
-   opens the app

To delete your feature branch and scratch org with the same name:

`npm run branch:delete BranchName`

This command:

-   deletes branch locally and remotely
-   destroys scratch org
-   switches to default branch

### Create Scratch Org Without Creating A Branch

If you want to just create a new Scratch Org and handle creating Feature Branches on your own (i.e. if you want to just have one scratch org for your entire sprint):

`npm run org:create OrgName`

Creation commands can have an optional second parameter of scratch org duration. The default is 15 (up from the sfdx default of 7) but you can set this number as high as 30. `npm run org:create OrgName 30`

This command:

-   creates a new scratch org aliased to branch name
-   pushes the dx metadata to scratch org
-   assigns the required permission set to your user
-   opens the app

To delete your scratch org:

`npm run org:delete OrgName`

This command:

-   destroys scratch org
-   switches to default branch

## Other Commands

### Switch branch and default scratch org

`./dx-utils/switch_branch.sh <branch-name>`

### Run unit tests

`./dx-utils/run_tests.sh`

### Run predefined anonymous apex scripts

Displays a menu of scripts from `dx-utils/apex-scripts`

`./dx-utils/run_apex.sh`

### Display SFDX Auth url (to store in CircleCI Environment Variables)

`sfdx force:org:display --verbose -u <org_alias>`

### generate package.xml from Managed/Unmanaged Package Container or ChangeSets

`./dx-utils/generatepkgXML.sh <org_alias> <packageName>`

Lets say the package Name is **Codescience** and org alias is **DevOrg** the command `./dx-utils/generatepkgXML.sh DevOrg "Codescience"` generates package.xml in Manifest folder .

## Seeing A New Repo

To seed a new repo, you may use most of what you see here. Be sure to remove the contents of the `force-app` directory as the version of CSUtils may be out of date - use the latest from the CSUtils repo.

## Code Formatting and Linting

If you prefer to have linting on each save, use the following. Linting will occur on commit with the Husky pre-commit hook.

Note: These steps are intended to be used with VSCode. If you use another IDE, please setup prettier and eslint to work with it or switch to VSCode.

-   Install Prettier [VSCode extension](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
-   Install VSCode [ESLint extension](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
-   Install [Apex PMD extension](https://marketplace.visualstudio.com/items?itemName=chuckjonas.apex-pmd)
-   In the root directory, run `npm install` to install necessary packages.
-   Add these attributes to your vscode workspace settings (.vscode/settings.json)

```
{
    "apexPMD.rulesets": ["pmd/pmd_rules.xml", "pmd/pmd_rules.CRUDFLS.xml"],
    "editor.codeActionsOnSave": {
        "source.fixAll": true
    },
    "editor.formatOnSaveTimeout": 5000,
    "eslint.format.enable": true,
    "eslint.lintTask.enable": true,
    "prettier.configPath": ".prettierrc",
    "prettier.requireConfig": true
}
```

## Slack

If you do not want slack integration on your build, remove the `slack/notify` nodes in `config.yml`
You can also customize these notifications, see the resources section

The Slack integration posts by default to the `#cs-circlebot-default` channel.
If you want to change the behavior, hardcode the channelId in the `channel:` parameter of the notification node

Example

```
- slack/notify:
    event: pass
    template: basic_success_1
    channel: "<my project's channel>"
    branch_pattern: 'integration,qa,clientqa,main'
```

## Resources

-   Trailhead: [Get Started with Salesforce DX](https://trailhead.salesforce.com/trails/sfdx_get_started)
-   Dev Hub [Trial Org Signup](https://developer.salesforce.com/promotions/orgs/dx-signup)
-   Dev Hub [Link Namespace to a Dev Hub Org](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_reg_namespace.htm)
-   CircleCI [Slack Integration](https://circleci.com/developer/orbs/orb/circleci/slack)
