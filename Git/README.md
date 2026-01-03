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

# Git stash
By default untracked files are not stashed, to include them use command:
```git stash -u```

git stash apply - keeps the changes in the stash
git stash pop - applies the changes but also removes them from the stash

``` 
git stash push -m "Stash message"
```
Creates a stash with message

Check the changes in a stash:
``` git stash show stash@{1} ```

Show with diff:
``` git stash show -p stash@{1} ```

Clear stashes:
``` git stash clear ```

Restore specific stash:
``` git stash pop stash@{2} ```

# Making important milestones
In Git, tags are used to mark specific points in a repository's history as being important. Typically, people use this functionality to mark release points (v1.0, v2.0, etc.).
Imagine you have just finished a feature and want to release it as Version 1.0. Here is how you would apply everything you learned:

### How to handle error: 'error: untracked working tree files would be overwritten by checkout' in git
This error occurs when there are changes in the working branch and without commit we change branch. 

labex:git-checkout-demo/ (main*) $ git checkout feature-branch
error: The following untracked working tree files would be overwritten by checkout:
	feature.md
Please move or remove them before you switch branches.
Aborting

How to resolve it:

One of the safest and most common way is using __git stash__
To stash untracked files use the --include-untracked option
```git stash push --include-untracked```
See a confirmed message.
Verify: 
```git status```
On branch main
nothing to commit, working tree clean
Push the stash again: git stash pop

Solution:
So before branching track the files or add to gitignore.
``` git add feature.md```
git commit -m "Add local version of feature.md"
git checkout feature-branch


There are two main types of tags you've explored:

1. Lightweight Tags
A lightweight tag is very much like a branch that doesn’t change—it’s just a pointer to a specific commit.

Example:
To create a lightweight tag at your current commit:

git tag v1.0-lw
2. Annotated Tags (Recommended)
Annotated tags are stored as full objects in the Git database. They contain the tagger name, email, date, and a message. These are recommended for public releases.

Example from your history:
You created an annotated tag for your first major release:

git tag -a v1.0 -m "First major release"
3. Tagging Later
You don't always have to tag the current commit. You can tag a commit from the past by specifying the commit checksum (or part of it).

Example from your history:
You tagged an earlier commit (f8f6906) with a specific version:

git tag v0.0.1 f8f6906
4. Viewing Tag Information
You can list tags or view the detailed information (especially useful for annotated tags).


The "One Example" Workflow

Mark the Release (Annotated Tag):
Create a tag with a descriptive message so your team knows what this version is for.

git tag -a v1.0 -m "Official release with area calculation features"
Verify the Tag:
Check the details to ensure the metadata is correct.

git show v1.0
Go Back in Time (Checkout):
If a bug is reported in this specific version later, you can travel back to exactly how the code looked at that moment.

git checkout v1.0
Clean Up (Delete):
If you realize you made a typo in the tag name (e.g., v1.0-wrong), you can remove it.

git tag -d v1.0-wrong
Key Takeaway
Use Annotated tags (-a) for your important project milestones because they act like a "signed document" in your Git history, recording who created the tag and why.

Examples:

List all tags: git tag
See tag details: git show v1.0 (This shows who tagged it, when, and the message you wrote).
Summary Checklist:
Action	Command
Create Annotated Tag	git tag -a <name> -m "message"
Create Lightweight Tag	git tag <name>
Tag Past Commit	git tag <name> <checksum>
List Tags	git tag
View Tag Details	git show <name>
Delete tag: git tag -d v0.0.1
