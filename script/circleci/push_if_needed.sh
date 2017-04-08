export BRANCH=master
if [ -n `git status -sb 2> /dev/null | grep minimum_wage.json` ] ; then
  git config --global user.email tky.c10ver@gmail.com
  git config --global user.name 'takaya1992'
  git add docs/
  git commit -m 'auto update'
  git branch -M $BRANCH
  git push origin $BRANCH
fi
