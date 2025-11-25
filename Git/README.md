# Git amend
This command is useful when you haven't pushed your commit to the remote repo and missed something from the LAST commit.
Without the -m flag, git will open the previous commit message and it can be editable.
Use:
git add hello.txt
git commit --amend -m "Initial commit with important note."

# Revert a commit
Saver than git reset because it creates a new commit.
In collab it's non destructive, so other commits won't be overwrite.
Running the command:
git revert HEAD
Then opens a text editor

# Cherry-Picking commits
Select a specific commit from one branch and apply it to your current branch.
Useful when you want to incorporate a particular feature or fix from another branch.
Most effective if you want to apply specific changes, fixes from one branch to another.
__Example__
Create a branch and a feature commit:
```
git checkout -b feature-branch
echo "This is a new feature" >> feature.txt
git add feature.txt
git commit -m "Add new feature"
```

```git checkout master```

Add new feature to main:
git cherry-pick feature-branch
* Instead of feature-branch you probably will search the commit hash:
git log --oneline

# Git rebase
For example we have three different commit and we want to combine them into one, and maybe we want to improve the commit message for "Third change". 
Rebase can be destructive to collaborators, rewriting shared history can cause problems.
if you made a mistake during interactive rebase use:
git rebase --abort
This will cancel the rebase operation and return your branch to the state it was in before you started the rebase process.

```
echo "First change" >> hello.txt
git commit -am "First change"
echo "Second change" >> hello.txt
git commit -am "Second change"
echo "Third change" >> hello.txt
git commit -am "Third change"
```

```git rebase -i HEAD~3```
-i for interactive
HEAD~3 Specifies the range of commits we want to rebase.

This will open the default text editor. Something like this:

1 pick 63c95db First change
2 pick 68e7909 Second change
3 pick 5371424 Third change
....
Commands:
pick (default)
reword (r): use the commit but allow you to change the commit message.
edit (e): Use the commit but stop the rebase process at this commit so you can make further changes (eg. amend files, add more changes)
squash (s): Combine this commit to the _previous_ commit in the list.
fixup (f): Similiar to squas but discards the commit message of this commit and just uses the message of the previous commit.
drop (d): Remove this commit entirely from the history.

Scenario: 
1. We want to squash second change into first change.
2. Reword third change to have a better message.
puck 63c95db First change
squash 68e7909 Second change
reword 5371424 Third change

Git will open the text editor:

```
# This is a combination of 2 commits.
# This is the 1st commit message:

First change

# This is the 2nd commit message:

Second change

# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
#
# Date:      Tue Oct 24 10:30:00 2023 +0000
#
# interactive rebase in progress; onto <base_commit_hash>
#
# Last commands done (2 commands done):
#    pick abc1234 First change
#    squash def5678 Second change
# Next command to do (1 remaining command):
#    reword ghi9101 Third change
# You are currently rebasing branch 'master' on '<base_commit_hash>'.
```

The editor will show the messages being squashed
After editing the message save and close the editor.

Next, rewording a commit.
Git will then move on to the reword command for Third change, and open the editor again
Change the commit message into more descriptive: 
Improved third change: Added a more descriptive line to hello.txt
Save, close. Check:
git log --oneline
Result:
<commit_hash_third_revised> Improved third change: Added a more descriptive line to hello.txt
<commit_hash_combined> Combined first and second changes: Initial setup of hello.txt
<commit_hash_cherry_pick> Add new feature
<commit_hash_revert> Revert "Add line to be reverted"
<commit_hash_original_reverted> Add line to be reverted
<commit_hash_initial_amended> Initial commit with important note

Extremely powerful command, use with caution. (Or exceptional cases)
With this command every commit can be modified differently just like before but from the first commit.
git rebase -i --root