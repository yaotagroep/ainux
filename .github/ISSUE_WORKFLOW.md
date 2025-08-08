# GitHub Issue Workflow Documentation

This document describes the comprehensive GitHub issue workflow system implemented for the Ainux OS project.

## 🎯 Overview

The issue workflow system provides:
- **Structured Issue Templates**: Pre-defined forms for different types of issues
- **Automated Labeling**: Automatic categorization and prioritization
- **Workflow Automation**: Auto-assignment, validation, and lifecycle management
- **Stale Issue Management**: Automated cleanup of inactive issues
- **Pull Request Validation**: Ensures PRs follow proper format and include required information

## 📝 Issue Templates

### Available Templates

1. **Bug Report** (`bug_report.yml`)
   - For reporting bugs and technical issues
   - Includes hardware information collection
   - Auto-labeled with `bug` and `triage`

2. **Feature Request** (`feature_request.yml`)
   - For suggesting new features or enhancements
   - Categorizes by feature type and priority
   - Auto-labeled with `enhancement` and `triage`

3. **Hardware Support Request** (`hardware_support.yml`)
   - For requesting support for specific hardware
   - Collects detailed hardware specifications
   - Auto-labeled with `hardware` and `enhancement`

4. **Documentation Issue** (`documentation.yml`)
   - For reporting documentation problems
   - Covers missing, incorrect, or unclear documentation
   - Auto-labeled with `documentation` and `triage`

### Configuration

The `config.yml` file:
- Disables blank issues to enforce template usage
- Provides links to community discussion and security reporting

## 🏷️ Label System

### Automatic Labeling

The system automatically applies labels based on:
- **Issue Title Prefixes**: `[BUG]`, `[FEATURE]`, `[HARDWARE]`, `[DOCS]`
- **Content Keywords**: GPU, NPU, build, cluster, network, performance, etc.
- **Priority Indicators**: Critical, urgent, important keywords

### Label Categories

#### Type Labels
- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Documentation improvements
- `duplicate` - Already exists
- `question` - Information request

#### Component Labels
- `gpu` - GPU-related issues
- `npu` - NPU-related issues
- `hardware` - Hardware support
- `build` - Build system related
- `cluster` - Cluster management
- `installation` - Installation and deployment
- `performance` - Performance improvements
- `networking` - Network-related issues
- `kernel` - Linux kernel related
- `ai-frameworks` - AI/ML framework integration

#### Priority Labels
- `priority:low` - Low priority
- `priority:medium` - Medium priority
- `priority:high` - High priority
- `priority:critical` - Critical priority

#### Status Labels
- `triage` - Needs triage
- `in-progress` - Currently being worked on
- `blocked` - Blocked by external dependency
- `needs-info` - More information needed
- `ready-for-review` - Ready for review
- `stale` - No activity for extended period
- `keep-open` - Do not mark as stale
- `security` - Security-related issue

## 🤖 Automated Workflows

### Issue Management Workflow

**Triggers**: Issue opened/edited, PR opened/edited/synchronized

**Features**:
- **Auto-labeling**: Applies relevant labels based on content
- **Triage Comments**: Welcomes new contributors
- **PR Validation**: Checks PR completeness

### Stale Issue Management

**Schedule**: Daily at midnight UTC

**Configuration**:
- **Issues**: Marked stale after 60 days, closed after 14 additional days
- **Pull Requests**: Marked stale after 30 days, closed after 7 additional days
- **Exempt Labels**: `keep-open`, `pinned`, `security`, `critical`

### Label Management

**Triggers**: Manual workflow dispatch

**Features**:
- Creates standard labels if they don't exist
- Updates existing labels to maintain consistency
- Ensures all component and priority labels are available

## 📋 Pull Request Template

The PR template includes:
- **Description Section**: Brief change summary
- **Type Classification**: Bug fix, feature, breaking change, etc.
- **Related Issues**: Links to fixed issues
- **Testing Information**: Environment and validation results
- **Checklist**: Code standards, review, documentation, tests

## 🔧 Usage Guide

### For Contributors

1. **Creating Issues**:
   - Select the appropriate template
   - Fill out all required fields
   - Use descriptive titles with proper prefixes
   - Include relevant system information

2. **Creating Pull Requests**:
   - Use the PR template format
   - Reference related issues
   - Include testing information
   - Complete the checklist

### For Maintainers

1. **Triage Process**:
   - Review auto-applied labels
   - Assign appropriate priority
   - Add component-specific labels if needed
   - Assign to relevant team members

2. **Label Management**:
   - Run the label management workflow to ensure all labels exist
   - Use consistent labeling across issues and PRs
   - Update label descriptions as needed

## 📊 Workflow Monitoring

### Issue Metrics
- Track issues by component and priority
- Monitor resolution times
- Identify common problem areas

### PR Metrics
- Review time tracking
- Testing completion rates
- Documentation update compliance

## 🛠️ Customization

### Adding New Templates
1. Create new `.yml` file in `.github/ISSUE_TEMPLATE/`
2. Follow GitHub's issue form syntax
3. Update label automation in `issue-management.yml`

### Modifying Labels
1. Update the label list in `label-management.yml`
2. Run the workflow to apply changes
3. Update documentation

### Adjusting Stale Settings
1. Modify timing in `stale.yml`
2. Update exempt labels as needed
3. Customize messages for your community

## 🔍 Troubleshooting

### Common Issues
- **Templates not appearing**: Check YAML syntax validity
- **Labels not applying**: Verify workflow permissions
- **Stale bot not working**: Check cron schedule and token permissions

### Debugging
- Review workflow run logs in GitHub Actions
- Validate YAML syntax with online tools
- Test templates by creating sample issues

## 📚 References

- [GitHub Issue Forms Documentation](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Labels Guide](https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/managing-labels)