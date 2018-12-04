## [0.4.0](https://github.com/littlebee/git-log-utils.git/compare/v0.3.0...v0.4.0) - (2018-12-03)

### Other Commits
* [9c9249e](https://github.com/littlebee/git-log-utils.git/commit/9c9249e739fb97005452db86ad1d6866b510ada1) Merge branch 'testBranch' of https://github.com/littlebee/git-log-utils
* [df64df4](https://github.com/littlebee/git-log-utils.git/commit/df64df47f72688cacbe6c2729e12c6ad95998773) this commit will be merged into master after I've made later changes.  seeing the effect this has on --since
* [f1d6855](https://github.com/littlebee/git-log-utils.git/commit/f1d68559da70cf3a5983337a36b7d9e0b03da59e) add --follow flag to track accross renames
* [a811f9d](https://github.com/littlebee/git-log-utils.git/commit/a811f9d3412cc82d061f6a7db106be01bbb2fdca) improve parsing - handle unicode control chars, better line break handling

## [0.3.0](https://github.com/littlebee/git-log-utils.git/compare/v0.2.2...v0.3.0) - (2018-09-16)
**Now returns files effected for each commit!**  

For single file queries, getCommitHistory will always return s single file in the `files` attribute that being the file requested.   For directory queries, `files` will contain only the files in the directory which were involved in the commit.  
### Other Commits
* [d3112c5](https://github.com/littlebee/git-log-utils.git/commit/d3112c5841e87bb150ecf6ed795c87bda300de9c) improve parsing of git log output; add files effected to commit objects returned
* [ffbeb0e](https://github.com/littlebee/git-log-utils.git/commit/ffbeb0ec561b73273aec8339fb6472868b667010) add - to escaped characters
* [003d9f3](https://github.com/littlebee/git-log-utils.git/commit/003d9f3be50c9d29f376d6f4d4ceb8c831093a92) adds missing development deps

## [0.2.2](https://github.com/littlebee/git-log-utils.git/compare/0.2.1...0.2.2) (2016-04-93)


### Bugs Fixed in this Release
* [72930e5](https://github.com/littlebee/git-log-utils.git/commit/72930e502afc18bf89288ead5c580c0b5540e2d7)  (unreported) parens in file name cause error.  better escaping for cli.

## [0.2.1](https://github.com/littlebee/git-log-utils.git/compare/0.2.0...0.2.1) (2016-03-89)


### Other Commits
* [c7dc6eb](https://github.com/littlebee/git-log-utils.git/commit/c7dc6eb469ebca55124ad7f12c696a130d6fe76d) fixes git-time-machine:issue#30. should handle spaces in directory and file names and properly escape and normalize file for windows

## [0.2.0](https://github.com/littlebee/git-log-utils.git/compare/0.1.6...0.2.0) (2016-03-87)
Thank you @Faleij the critical windows fix.   Did I ever tell you, you're my hero. :)

### New Features
* [25c137c](https://github.com/littlebee/git-log-utils.git/commit/25c137cfa9f1c9f223f71ac49c335f4ab6aa0a25)  now working on windows!

### Other Commits
* [929370b](https://github.com/littlebee/git-log-utils.git/commit/929370b386669af1705249384efba5a6a04d849d) origin/master

## [0.1.6](https://github.com/littlebee/git-log-utils.git/compare/0.1.5...0.1.6) (2016-03-79)
remove accidental console.log left behind

## [0.1.5](https://github.com/littlebee/git-log-utils.git/compare/0.0.0...0.1.5) (2016-03-78)


### Bugs Fixed in this Release
* [899e63c](https://github.com/littlebee/git-log-utils.git/commit/899e63cc6314af5672ee1674116e4a6037f752c8)  fix for path errors on windows surfacing in git-time-machine see issue 22 in that repo
