Config = {}

Config.ShameyDebug = false
Config.PrintDebug = false

Config.DbUpdateIntervalInSeconds = 120

Config.WithdrawalIncrementIntervalInSeconds = 60

Config.WithdrawalHealthHitThreshold = 70
Config.WithdrawalHealthHitAmountInner = 5
Config.WithdrawalHealthHitAmountOuter = 50
Config.WithdrawalHealthHitIntervalInSeconds = 2 * 60

Config.DependencyDecrementIntervalInSeconds = 3 * 60
Config.DependencyDecrementAmount = 1


-- Dependency is out of 10
-- Withdrawal is out of 100
Config.Vices = {
    ["coffees"] = {
        id = "coffees",
        dependencyThreshold = 5,
        dependencyIncrement = 1,
        withdrawalIncrement = 0.1,
        itemNames = {
            "consumable_coffee",
        },
    },
    ["alcohols"] = {
        id = "alcohols",
        dependencyThreshold = 3,
        dependencyIncrement = 1,
        withdrawalIncrement = 0.5,
        itemNames = {
            "tequila",
            "vodka",
            "whisky",
            "beer",
            "blackberryale",
            "raspberryale",
            "wildCiderMoonshine",
            "moonshine",
            "wine",
            "tropicalPunchMoonshine",
            "appleCrumbMoonshine",
        },
    },
    ["cigarettes"] = {
        id = "cigarettes",
        dependencyThreshold = 2,
        dependencyIncrement = 1,
        withdrawalIncrement = 1,
        itemNames = {
            "cigarette",
            "cigar"
        },
    },
    ["ganjas"] = {
        id = "ganjas",
        dependencyThreshold = 2,
        dependencyIncrement = 1,
        withdrawalIncrement = 1,
        itemNames = {
            "ganja_cigarette",
        },
    },
}


