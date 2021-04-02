library(ggplot2)
library(ggridges)

calc.aggregate = function(d) {
    numeric_cols <- unlist(lapply(d, is.numeric))
    d = d[ ,numeric_cols]
    dmax = aggregate(. ~ trueSpCompRate, d, max)
    dmin = aggregate(. ~ trueSpCompRate, d, min)
    dmean = aggregate(. ~ trueSpCompRate, d, mean)
    dmean$ciLow = dmin$ciLow
    dmean$ciHigh = dmax$ciHigh
    return(dmean)
}

plot.estSpeciesCompletionRate = function(d) {
    dmean = calc.aggregate(d)
    d$trueSpCompRateLevel = factor(d$trueSpCompRate)
    xmarks = c(0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.10)
    p = (
        ggplot(d, aes(trueSpCompRate, estSpCompRate))
        # + geom_pointrange(aes(ymin=ciLow, ymax=ciHigh, colour=factor(d$numSpecies)))
        # + geom_pointrange(aes(ymin=ciLow, ymax=ciHigh, colour=d$numSpecies)) + scale_colour_gradientn(colours=rainbow(10), name="True Partition Size")
        # + geom_pointrange(aes(ymin=ciLow, ymax=ciHigh, colour=d$numSpecies)) + scale_colour_viridis_c(name="True Partition Size")
        + geom_point(aes(ymin=ciLow, ymax=ciHigh, colour=d$numSpecies)) + scale_colour_viridis_c(name="True Partition Size")
        # + geom_pointrange(aes(ymin=ciLow, ymax=ciHigh))
        + geom_abline(intercept=0, slope=1, colour="888888")
        + geom_ribbon(data=dmean, mapping=aes(x=trueSpCompRate, ymin=ciLow, ymax=ciHigh), alpha=0.3)
        + scale_x_continuous(limits=c(min(d$trueSpCompRate), max(d$trueSpCompRate)), breaks=xmarks, labels=paste(xmarks))
        + scale_y_continuous(limits=c(min(d$ciLow), max(d$ciHigh)))
        + xlab("True Speciation Completion Rate")
        + ylab("Estimated Speciation Completion Rate")
        + theme(legend.position="bottom")
        # + xlim(0.0, 0.1)
        # + ylim(0.0, 0.1)
        )
    return(p)
}

# plot.EstSpeciesCompletionRate.aggregate = function(d) {
#     dmean = calc.aggregate(d)
#     p = (
#         ggplot(dmean, aes(trueSpCompRate, estSpCompRate))
#         + geom_pointrange(aes(ymin=ciLow, ymax=ciHigh))
#         + geom_abline(intercept=0, slope=1, colour="888888")
#         + geom_ribbon(aes(ymin=ciLow, ymax=ciHigh), alpha=0.3)
#         + scale_x_continuous(limits=c(min(d$trueSpCompRate), max(d$trueSpCompRate)))
#         + scale_y_continuous(limits=c(min(d$ciLow), max(d$ciHigh)))
#         )
#     return(p)
# }

# plot.estSpeciesCompletionRate.densities = function(d) {
#     p = (
#         ggplot(d, aes(as.factor(trueSpCompRate), estSpCompRate))
#         + geom_violin()
#         + scale_y_continuous(limits=c(min(d$ciLow), max(d$ciHigh)))
#         )
#     return(p)
# }

# plot.estSpeciesCompletionRate2 = function(d) {
#     dmean = calc.aggregate(d)
#     p = (
#         ggplot(d, aes(trueSpCompRate, estSpCompRate))
#         + geom_point(aes(colour=factor(d$numSpecies)))
#         # + geom_pointrange(aes(ymin=ciLow, ymax=ciHigh, colour=factor(d$numSpecies)))
#         + geom_abline(intercept=0, slope=1, colour="888888")
#         # + geom_ribbon(aes(x=trueSpCompRate, ymin=ciLow, ymax=ciHigh), alpha=0.3)
#         + scale_x_continuous(limits=c(min(d$trueSpCompRate), max(d$trueSpCompRate)))
#         + scale_y_continuous(limits=c(min(d$ciLow), max(d$ciHigh)))
#         )
#     return(p)
# }

# plot.estSpeciesCompletionRate.points = function(d) {
#     p = (
#         ggplot(d, aes(trueSpCompRate, estSpCompRate))
#         + geom_point(aes(colour=factor(d$numSpecies)))
#         + scale_x_continuous(limits=c(0,0.1))
#         + scale_y_continuous(limits=c(0,0.1))
#         + geom_abline(intercept=0, slope=1, colour="888888")
#         )
#     return(p)
# }

# plot.estSpeciesCompletionRate.pointrange = function(d) {
#     p = (
#         ggplot(d, aes(trueSpCompRate, estSpCompRate))
#         + geom_pointrange(aes(ymin=ciLow, ymax=ciHigh, colour=factor(d$numSpecies)))
#         + scale_x_continuous(limits=c(0,0.1))
#         + scale_y_continuous(limits=c(0,0.1))
#         + geom_abline(intercept=0, slope=1, colour="888888")
#         )
#     return(p)
# }

# plot.estSpeciesCompletionRate1 = function(d) {
#     p = (
#         ggplot(d, aes(trueSpCompRate, estSpCompRate))
#         + geom_point(aes(colour=factor(d$numSpecies)))
#         # + geom_pointrange(aes(ymin=ciLow, ymax=ciHigh, colour=factor(d$numSpecies)))
#         + geom_abline(intercept=0, slope=1, colour="888888")
#         # + geom_ribbon(aes(x=trueSpCompRate, ymin=ciLow, ymax=ciHigh), alpha=0.3)
#         + scale_x_continuous(limits=c(min(d$trueSpCompRate), max(d$trueSpCompRate)))
#         + scale_y_continuous(limits=c(min(d$ciLow), max(d$ciHigh)))
#         )
#     return(p)
# }

