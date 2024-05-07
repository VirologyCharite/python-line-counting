# Counting lines of Python code in .py and .ipynb files

Here are two scripts for counting non-blank non-comment lines of code in
Python or Jupyter (iPython) notebook files.

## Requirements

You will need [nbdime](https://nbdime.readthedocs.io/en/latest/), which can
be installed via `pip install nbdime`.

## Usage

Usage is just to give the filenames on the command line.

Or, to recursively examine a directory, use `xargs`.

For example, here is our `SARS-2-ANOVA` directory:

```sh
$ find . -name '*.ipynb' | grep -v ipynb_checkpoints | xargs nb-count-lines.sh
      31	./docs/terry/B117-genome-comparisons/notebook.ipynb
     337	./notebooks/cusma/vlDaysPostOnsetStan.ipynb
     648	./notebooks/cusma/overview.ipynb
     199	./notebooks/cusma/overviewSymptoms.ipynb
    1082	./notebooks/cusma/allDataPlots.ipynb
     402	./notebooks/cusma/symptomPlots.ipynb
     447	./notebooks/cusma/repeatedTesting.ipynb
    1813	./notebooks/cusma/paper.ipynb
     713	./notebooks/cusma/logisticRegression.ipynb
     245	./notebooks/cusma/agrdtComparisonVictor.ipynb
     115	./notebooks/cusma/testlineRegression.ipynb
      47	./notebooks/cusma/T1_T2_diff.ipynb
     152	./notebooks/cusma/revision.ipynb
     334	./notebooks/cusma/linearRegression.ipynb
     908	./notebooks/paper-2/reinfections.ipynb
     139	./notebooks/paper-2/vlCourses.ipynb
    1332	./notebooks/paper-2/vlDeltasRegression.ipynb
    1120	./notebooks/paper-2/regression.ipynb
     157	./notebooks/paper-2/vlVariants.ipynb
    1714	./notebooks/paper-2/vlDeltasPlots.ipynb
      57	./notebooks/cohort/chariteCohort.ipynb
     771	./notebooks/cohort/201103-playing.ipynb
     408	./notebooks/cohort/201028-vl-statistics.ipynb
     137	./notebooks/cohort/cohortViralLoadPlots.ipynb
      36	./notebooks/starsigns/horoscope.ipynb
     119	./notebooks/paper-1/combined-500K.ipynb
     116	./notebooks/paper-1/figa3-a4.ipynb
     451	./notebooks/paper-1/children-barbara.ipynb
      83	./notebooks/paper-1/DunnsTest.ipynb
     462	./notebooks/paper-1/ANOVA.ipynb
     185	./notebooks/paper-1/reproducing-guido-bayes.ipynb
     236	./notebooks/paper-1/PCR-timeseries.ipynb
     203	./notebooks/paper-1/children.ipynb
   15199	TOTAL
```

Note that in the above I am not using `print0` on the find with the
corresponding `-0` to `xargs`. That's because I wanted to easily filter out
the `ipynb_checkpoints` files (I could have done it with `-print0` and
`perl`, but whatever). You should probably use `-print0` and `-0` because
Jupyter notebook files will often have spaces in their names and this will
break things.

Here's the tail end of the Python in that dir:

```sh
$ find . -name '*.py' -print0 | xargs -0 py-count-lines.sh | tail -n 20
     443	./data/labor_berlin_panels/results.py
       0	./data/labor_berlin_panels/__init__.py
      86	./data/labor_berlin_panels/names.py
     141	./data/labor_berlin_panels/parse.py
     487	./data/labor_berlin_panels/globalVars.py
    1016	./data/cohort/produce-tsv.py
      21	./data/cohort/extract-matched-person-hash-lines.py
     136	./data/labor28/20200624-to-tsv.py
     183	./data/labor-berlin-serology/produce-tsv.py
      15	./data/labor-berlin-serology/anonymize-tsv.py
       0	./data/tgfb_nk/test/__init__.py
      26	./data/tgfb_nk/test/test_headers.py
     154	./data/tgfb_nk/nk-to-tsv-format-2.py
       0	./data/tgfb_nk/__init__.py
      76	./data/tgfb_nk/nk-to-tsv-format-3.py
     193	./data/tgfb_nk/nk-to-tsv-format-4.py
     112	./data/tgfb_nk/nk-to-tsv-format-5.py
     142	./data/tgfb_nk/nk-to-tsv-format-1.py
      29	./data/tgfb_nk/headers.py
   61178	TOTAL
```

## Thoughts

Code in `*.ipynb` files is almost certainly not tested. Same goes for code
in `bin/*.py` scripts. How much of those things do you have? In recent
years, I have almost zero in the first category and still way too much in
the second category (not to mention way too much untested code in shell
scripts).

What would you consider to be a (very generally) healthy ratio of untested
to overall code? Of notebook to raw python code?

In `dark-matter` sub-directories, the Python line counts are

    bin  13,019
    dark 23,665
    test 37,780
    
So about 1/3rd of the non-test code (13K/36K) is in `bin` and is definitely
not tested. And of the code that could be tested (in `dark`), the testing
code has about 1.5 times as many lines as the tested code. I'm not sure
what the coverage is, but I don't think it would be above 75%.

In `bih-pipeline` sub-directories, the line counts are

    bin              2518
    civ_bih_pipeline 3481
    test             4407

Anyway, what about your code?

## Implementation details

In `nb-count-lines.sh` there are a few things that may seem mysterious.

* `nbdime` throws a JSON decode exception if it is given an empty file, so I
   test for that with `if [ -s "$file" ]`.
* When I know a file is empty, I still "count" its lines via `lines=$(echo -n '' | wc -l)`.
    That results in output that matches the `wc -l` output from the non-empty files, and
    so is correctly indented.
* `nbdime` prints escape codes to colour its output, with no option to turn
  that off. You can view it nicely with `less -R`. But I don't want those
  escape codes so I remove them with a bit of `perl`.
