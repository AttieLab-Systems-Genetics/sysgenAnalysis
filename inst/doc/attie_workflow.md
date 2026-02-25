# Attie Workflow

```
From: Alan Attie <adattie@wisc.edu>
Sent: Friday, February 20, 2026 7:48:01 AM
Subject: QTL analyses
```

Thus far, we have prioritized QTL hotspots in our analyses. However, I find many isolated metabolites and RNAs to be of interest. However, there are a large number of them, so I want to develop a workflow that helps to carry out multiple rather tedious steps in the analyses.

Here is what I was doing yesterday. It is extremely low-throughput and inefficient.

I would manually scan for phenotypes of interest (e.g. lipids, glycolytic intermediates, carnitine esters, organic acids).

- I checked the LOD scores to be sure they look reasonable.
- I look at the allele effects to find "significant" contrast (obviously redundant with looking at the LOD score)
- I grabbed the location of the LOD peak, went to the UCSC genome browser and displayed all of the genes within 0.5 Mb of the peak.
- I manually looked at these genes to look for a biochemically plausible driver.

This is of course pretty inefficient. But on top of that, I would want to do the following:

- Look for other metabolites, lipids, or RNAs that co-map with this feature.
- Look for other metabolites, lipids, or RNAs whose abundance correlates with the feature.
- Look for any phenotypes in human GWAS that map to this region.

The first step in the first list has to be manual because I don't think there is any prompt that would faithfully replicate my own subjective judgement. I'm OK with that.
After that first step, I'd like to flag all of the features of interest and then have an automated workflow to do the rest of the steps. I'm not sure how I would structure the output. I guess the simplest thing would be a report for each feature in the form of a series of Powerpoint slides. This would generate a giant Powerpoint deck, which I could then read carefully and flag features for even more detailed follow-up.
