# Review packet

Read this when writing the reviewer's packet. The reviewer starts with no access to this conversation, and an open-ended packet sends it into folders it should not read, so the packet names exactly what to read. The reviewer's rules file already sets the reply format (severity, `path:line`, `No findings.`); do not repeat it.

First write the inputs into the run folder:

```bash
git -C <repo> diff <base>...<head> > <run folder>/review.diff
git -C <repo> log --oneline <base>..<head> > <run folder>/review-commits.txt
```

The three-dot diff shows what `<head>` changed since it left `<base>`, which matches the pull request view.

Save the packet as `<run folder>/review-packet.md`:

```markdown
# Packet: review <base>..<head>

## Goal

Review the changes in `<base>..<head>` for defects: <one line on what the change does, from the spec's Goal>.

## Use

- Working directory: `<review checkout>`, checked out at `<head>`. Read code only here.
- Read exactly these, and nothing else in the run folder:
  - Diff: `<run folder>/review.diff`
  - Commits: `<run folder>/review-commits.txt`
  - Spec: `<repo>/context/specs/<spec>.md`. Read its Goal, Approach, and Validation.
- Files and areas in scope: <the changed files, plus callers or shared interfaces worth reading, with paths>.
- Look closely at the spec's Review risks: <quote them>.

## Return

Reply in the pane with your findings, following your rules.

## Stop if

- A file you need is outside the scope above. Name it and stop instead of reading it.
```

Fill in every `<...>`. Leave out the run folder's other files, including result files and earlier packets: they carry the implementer's view, and the reviewer should form its own.
