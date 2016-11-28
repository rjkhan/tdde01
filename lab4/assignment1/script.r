library("tree")
library("boot")
library("ggplot2")
library("grDevices")

state <- read.csv2("state.csv")
state <- state[order(state$MET),]

setEPS()
cairo_ps("state.eps")
print(qplot(EX, MET, data = state,
            geom = c("point")))
dev.off()

set.seed(12345) # Not really required here.
control <- tree.control(nrow(state), minsize = 8)
fit <- tree(EX ~ MET, data = state, control = control)
optimal <- cv.tree(fit) # Gives best number of leaves.
o <- which.min(optimal$dev) # Best index reg. deviance.
optimaltree <- prune.tree(fit, best = optimal$size[o])
EXhat <- predict(optimaltree, newdata = state)

setEPS()
cairo_ps("besttree.eps")
plot(optimaltree)
text(optimaltree)
dev.off()

setEPS()
cairo_ps("beststate.eps")
print(qplot(EXhat, MET, data = state,
            geom = c("point")))
dev.off()

setEPS()
cairo_ps("histresid.eps")
hist(residuals(optimaltree))
dev.off()

bootfn <- function(data, indices) {
    sample <- data[indices,]
    control <- tree.control(nrow(sample), minsize = 8)
    fit <- tree(EX ~ MET, data = sample, control = control)
    optimaltree <- prune.tree(fit, best = optimal$size[o])
    EXhat <- predict(optimaltree, newdata = data)
    return(EXhat)
}

bootstrap <- boot(state, bootfn, R = 1024)

setEPS()
cairo_ps("bootstrap.eps")
plot(bootstrap)
dev.off()

cb <- envelope(bootstrap)
