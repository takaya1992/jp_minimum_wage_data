export BRANCH=master
diff=`git status -sb 2> /dev/null | grep minimum_wage.json`
if [ -n diff ] ; then
  git config --global user.email tky.c10ver@gmail.com
  git config --global user.name 'takaya1992'
  git add docs/
  git commit -m 'auto update [ci skip]'
  git branch -M $BRANCH
  git push origin $BRANCH
fi
