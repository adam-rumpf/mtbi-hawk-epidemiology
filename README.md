# Determination of Tucson, Arizona as an Ecological Trap for Cooper's Hawks (_Accipiter cooperii_)

This repository contains the MATLAB scripts used for an undergraduate group research project that I participated in at the [Mathematical and Theoretical Biology Institute (MTBI)](https://mtbi.asu.edu/) 2011 Summer program. The paper may be found here:

> J. Ames, A. Feiler, G. Mendoza, A. Rumpf, and S. Wirkus. Determination of Tucson, Arizona as an Ecological Trap for Cooper's Hawks (Accipiter cooperii). Unpublished manuscript, 2011, https://mtbi.asu.edu/2011-2.

The project involved studying a protozoan disease (_Trichomonas gallinae_) as it affects the Cooper's Hawk (_Accipiter cooperii_). Several mathematical models were created to study this disease, including a deterministic ODE-based model and several stochastic analogs of the deterministic model. The programs included in this repository were used to generate the computational results in the paper.

I would not really expect these files to be of use to anyone outside of our research group, and most of them will not make sense unless you have read the paper (linked above), but they are provided here for anyone interested. The individual files are described below. Note that the name of our research group was "Fancy Birds", which is why many of the files are named that.

## File Description Format

`filename.m`
Description of the function.
`> command line input` (shown as "`---`" if it was called by another function rather than directly from the command line)

## Plotting the real _H*_ conditions

`beta_sigma_d.m`
Used to plot the real _H*_ boundary for _d_ vs _σ_ with varying _β_. Included in paper as Figure 6.
`> beta_sigma_d`

`d_sigma_beta.m`
Used to plot the real _H*_ boundary for _β_ vs _σ_ with varying _d_. Included in paper as Figure 5.
`> d_sigma_beta`

`sigma_d_beta.m`
Used to plot the real _H*_ boundary for _β_ vs _d_ with varying _σ_. Included in paper as Figure 7.
`> sigma_d_beta`

`sigma_beta_d_3d_corner.m`
Used to combine the results from `beta_sigma_d.m`, `d_sigma_beta.m`, and `sigma_d_beta.m` into a single 3D plot. Included in the paper as Figure 8.
`> sigma_beta_d_3d_corner`

## Bifurcation diagrams

`equilibrium_bifurcation_beta.m`
Used to generate a bifurcation diagram for _H*_ versus _β_. Included in paper as Figure 9.
`> equilibrium_bifurcation_beta`

`equilibrium_bifurcation_deaths.m`
Used to generate a bifurcation diagram for _H*_ versus _d_ (as a percentage). Included in paper as Figure 10.
`> equilibrium_bifurcation_deaths`

## Stochastic model (Markov chain)

`fancy_birds.m`
The main stochastic model utilizing a Markov chain with event rates based on our system of ODEs. Allows the user to specify initial conditions and the _σ_ value. Outputs a vector of the total number of each event type which occurred during the simulation, as well as a plot of each population class over time. Used to generate Figure 14. A cleaner version of this file is included in Appendix C under the name `hawk_markov.m`.
`> fancy_birds(1000000,1825,200,200,100,0,0.423,1)` for Figure 14 (showing 10 realizations with `hold` on)

`fancy_birds_comparison.m`
Runs `fancy_birds.m` many times and averages the final statistics from each realization. Used to obtain the average population growth for a variety of _σ_ values. The results from these runs are plotted in Figure 12.
`> fancy_birds_comparison(250,[[0:0.01:0.1],[0.2:0.1:1]])`

`fancy_birds_beta.m`
The same as `fancy_birds.m`, but allows the user to specify _β_ instead of _σ_.
`---`

`fancy_birds_comparison_beta.m`
The same as `fancy_birds_comparison.m`, but instead runs `fancy_birds_beta.m` for a variety of _β_ values. The results from these runs are plotted in Figure 11.
`> fancy_birds_comparison_beta(250,linspace(0.0005,0.0035,21))`

`fancy_birds_d.m`
The same as `fancy_birds.m`, but allows the user to specify _d_ instead of _σ_.
`---`

`fancy_birds_comparison_d.m`
The same as `fancy_birds_comparison.m`, but instead runs `fancy_birds_d.m` for a variety of _d_ values. The results from these runs are plotted as Figure 13.
`> fancy_birds_comparison_d(250,linspace(0,0.025,26))`

## Stochastic model (alternate)

`fancier_birds.m`
The alternate, more realistic stochastic model. Used to track various classes of a hawk population for a specified amount of time. Outputs a vector of various statistics about the process results, as well as a plot of either every individual class or the classes grouped into adults and nestlings.
`> fancier_birds(365,200,1)` for Figure 15
`> fancier_birds(1825,200,2)` for Figure 16 (showing 10 realizations with `hold` on)

`fancier_birds_d.m`
The same as `fancier_birds.m`, but allows the user to specify a _d_ value.
`---`

`fancier_birds_comparison_d.m`
Runs `fancier_birds_d.m` many times and averages the final statistics from each realization. Used to obtain the average population growth from our default parameters, discussed in Section 3.3.
`> fancier_birds_comparison_d(1000,0.41)`

## Deterministic Model

`newmodel.m`
Function containing the equations for system (1)-(4).
`---`

`plotNM.m`
Calls `newmodel.m` and plots the solution of the ODE in days, with our current parameters. Produces Figure 2
`>plotNM(365)`
To produce Figure 3 we change the values of _d=.73/40_ (73% die from the disease), _γ=.27/40_ (27% recovers from the disease) and run for 600 days.
`>plotNM(600)`
Figure 4 is given by changing values of _γ=.26/40_ (26% recovers from the disease), _d=.74/40_ (74% die from the disease) and run for 365 days.
`>plotNM(365)`
