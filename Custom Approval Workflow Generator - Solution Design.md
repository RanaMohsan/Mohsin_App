# Custom Approval Workflow Generator

## Executive Summary

The `Custom Approval Workflow Generator` is a metadata-driven Business Central solution that enables customers to scaffold approval workflow integration for custom tables and pages without writing manual AL code for each new document. It is built as a code generation and deployment layer on top of standard Business Central approval and workflow capabilities.

This deliverable documents the current solution architecture, functional design, implementation objects, and deployment considerations for SaaS and OnPrem environments.

---

## Business Problem

Organizations implementing Business Central often need to add approval workflows to custom documents (tables and pages) for compliance, governance, and business process control. Traditionally, this requires:

- Manual AL development for each custom document
- Repetitive coding of approval actions, status transitions, and workflow integration
- High development effort and maintenance overhead
- Risk of inconsistent implementation across custom documents
- Limited ability for functional consultants to configure without developer involvement

The solution addresses these challenges by providing a no-code/low-code configuration experience that generates standardized approval integration code automatically.

---

## Solution Overview

### Core capabilities

- Metadata-driven setup page for workflow configuration.
- Template-based AL generation for page extensions and approval logic.
- Code editor preview and management for generated AL.
- Workflow template creation and registration in standard Workflow tables.
- Deployment orchestration using Instant Deploy and Schedule Deploy actions.
- Support for GitHub Actions-style dispatch workflows and BC Admin Center integration.

### Primary user personas

- Solution Architect: validates design and extension packaging.
- Functional Consultant: configures approval workflow for custom documents.
- AL Developer: reviews generated AL, customizes and packages extensions.
- Implementation Lead: coordinates deployment and production rollout.

---

## One-Line Product Definition

A metadata-driven code generation framework that eliminates repetitive approval integration for custom Business Central documents by automatically generating standardized AL code, registering workflow templates, and enabling standard Business Central workflow usage through a configuration-driven setup page.

---

## End-to-End Conceptual Explanation

The solution operates as a scaffolding engine that bridges custom document requirements with standard Business Central approval capabilities:

1. **Configuration Phase**: Functional consultants configure approval metadata through a setup page, specifying table/page IDs, status fields, document numbers, and workflow parameters.

2. **Code Generation Phase**: The system generates AL page extensions with approval actions, status handling, and workflow integration using templates and placeholders.

3. **Workflow Registration Phase**: Standard Business Central workflow templates are created and registered, enabling reuse of the built-in workflow engine.

4. **Deployment Phase**: Generated extensions are deployed via instant or scheduled publishing, with monitoring and rollback capabilities.

5. **Runtime Phase**: End users interact with approval actions on custom pages, triggering status transitions and standard approval workflows.

### Workflow Integration and Runtime Behavior

The solution integrates seamlessly with standard Business Central workflow capabilities:

**Standard Business Central Functionality Used:**
- **Workflow Management**: Uses `Codeunit "Workflow Management"` to handle workflow events
- **Approval Entries**: Leverages standard `Approval Entry` table for approval tracking
- **Workflow Templates**: Creates and registers templates in standard `Workflow` and `Workflow Category` tables
- **Status Transitions**: Supports standard approval lifecycle (Open → Pending → Approved/Rejected → Released)
- **Approvals Management**: Approval actions appear on pages with proper user permission controls

**Custom Framework Components:**
- **Setup Configuration**: Metadata-driven configuration in `Custom Approval Workflow Setup` table
- **Code Generation**: Template-based AL generation using `AL Page Extension Generator` codeunit
- **Workflow Template Builder**: Creates standard workflow templates with `Codeunit "Workflow Template Builder"`
- **Management Codeunit**: `Custom Approval Workflow Mgt.` handles approval actions and status updates
- **Deployment Orchestration**: Scheduled/instant deployment via `WF Deploy Scheduler Mgt.`

**Generated Objects:**
- **Page Extensions**: AL code with approval actions (Send/Cancel/Approve/Reject) using RecordRef for generic table support
- **Workflow Templates**: Registered in standard BC workflow tables for reuse
- **AL Source Code**: Generated page extensions with status field handling and workflow event integration

### Workflow Integration Details

**Workflow Template Creation:**
- `Create Workflow Template` action creates/updates `Workflow Category` and `Workflow` records
- Templates are marked as templates and can be activated in standard BC Workflow UI
- Workflow codes and descriptions are configured in the setup page

**Approval Actions in Generated Code:**
- **Send Approval Request**: Triggers workflow event and updates status to "On Pending Document"
- **Cancel Approval Request**: Cancels workflow and reverts status to "On Open Document"  
- **Approve**: Updates approval entry to Approved and sets status to "On Approve Document"
- **Reject**: Updates approval entry to Rejected and sets status to "On Reject Document"

**Status Field Integration:**
- Generated code uses RecordRef.Field() to access configured status fields dynamically
- Status transitions follow the mappings defined in setup (Send When, Cancel When, On Open/Pending/Approve/Reject/Release)
- Supports any enum-based status field with WFDemo Status values

**Workflow Event Handling:**
- Uses standard `WorkflowManagement.HandleEvent()` for workflow lifecycle
- Events include APPROVAL_REQUEST_SENT and APPROVAL_REQUEST_CANCELLED
- Integrates with standard BC approval workflow engine

**Approval Entry Management:**
- Leverages standard Approval Entry table for tracking pending approvals
- Checks user permissions using "Approver ID" = UserId and Status = Open
- Updates entry status on approve/reject actions

---

## Detailed Business Objectives

- Eliminate repetitive approval code development for custom documents.
- Provide a setup-driven configuration experience for non-developers and functional consultants.
- Generate approval-related AL artifacts automatically from metadata.
- Deploy generated extensions through instant or scheduled publish flows.
- Register and manage workflow templates that can be used by standard Business Central Workflow.
- Preserve standard Business Central workflow lifecycle and security.
- Enable status transitions (Open → Pending → Approved/Rejected → Released).
- Support approval actions appearing on custom pages with proper visibility controls.
- Integrate seamlessly with standard Business Central Approvals Management.
- Provide clear distinction between framework components and generated/runtime elements.

---

## Scope and Out-of-Scope Items

### In Scope
- Configuration of custom tables and pages for approval workflows.
- Generation of page extensions with approval actions.
- Status field mapping and transitions.
- Workflow template creation and registration.
- Deployment scheduling and monitoring.
- Integration with standard BC workflow and approval systems.
- SaaS and OnPrem deployment considerations.
- Code editor for AL preview and management.

### Out of Scope
- Custom workflow engine development (uses standard BC workflow).
- Advanced workflow routing logic (handled by standard workflow steps).
- Integration with external approval systems.
- Mobile approval interfaces.
- Multi-company approval scenarios.
- Custom approval entry tables (uses standard BC approval entries).

---

## End-to-End Process Flow

1. **Setup Configuration**
   - Access `Custom Approval Workflow` page.
   - Select target table and configure status/document fields.
   - Define workflow category and template details.
   - Configure deployment settings.

2. **Code Generation**
   - Click `Generate Code` to create AL page extension.
   - Review generated code in `Code Editor Workflow AL`.
   - Download or reset code as needed.

3. **Workflow Template Creation**
   - Click `Create Workflow Template` to register in standard BC workflow.
   - Template appears in `Workflow Templates` for configuration.

4. **Deployment**
   - Use `Auto Deploy Scheduler` for instant or scheduled publishing.
   - Monitor deployment status and run URLs.

5. **Runtime Usage**
   - Approval actions appear on custom pages based on user permissions.
   - Status transitions occur through standard workflow events.
   - Approvals managed via standard BC approval pages.

---

## Setup Page Detailed Explanation

The main configuration page is `Custom Approval Workflow` (page `80112`). It exposes the following groups:

### General
- **`No.`**: Identifier for this workflow configuration. Starts as temporary (TMP…) and becomes permanent after status field selection.
- **`Table No.` (Table ID)**: Target table for the workflow. Selected from all available tables.
- **`Table Name`**: Caption of the selected table (auto-filled).
- **`Enabled`**: Enables/disables this configuration.

### Status Configuration
- **`Status Field No.`**: Field number of the status field on the target table (lookup from table fields).
- **`Status Field Name`**: Name of the status field (auto-filled).
- **`Send Approval When`**: Status value when approval can be sent (e.g., Open).
- **`Cancel Approval When`**: Status value when approval can be cancelled (e.g., Pending).
- **`On Open Document`**: Status mapped to open document.
- **`On Pending Document`**: Status mapped to pending document.
- **`On Approve Document`**: Status after approve (e.g., Approved).
- **`On Reject Document`**: Status after reject (e.g., Rejected).
- **`On Release Document`**: Status when released (e.g., Released).

### Document Configuration
- **`Document No. Field No.` (Document No.)**: Field number used as document number (lookup from table fields).
- **`Document No. Field Name`**: Field name used as document number (auto-filled).
- **`Card Page ID` (Page ID)**: Card page to extend with approval actions.
- **`Card Page Name`**: Name of the card page (auto-filled).

### Workflow Configuration
- **`Workflow Category Code`**: Category for generated workflow templates (lookup from standard Workflow Category).
- **`Workflow Category Description`**: Description of the workflow category.
- **`Workflow Code`**: Code of the workflow to create or update.
- **`Workflow Description`**: Description of the workflow.

### Deployment Configuration
- **`Deploy Repo Owner`**: GitHub repository owner for deployment workflow dispatch.
- **`Deploy Repo Name`**: GitHub repository name.
- **`Deploy Branch`**: Git branch used for workflow dispatch (default: main).
- **`Deploy Workflow File`**: Workflow file name in .github/workflows (e.g., PublishToEnvironment.yaml).
- **`Deploy PAT Token`**: GitHub token with Actions workflow dispatch permission.

### Deployment Monitoring
- **`Last Scheduled At`**: Last time a deploy job was scheduled.
- **`Last Deploy At`**: Last deployment execution time.
- **`Last Deploy Status`**: Latest deployment status (None, Scheduled, Queued, Success, Failed).
- **`Last Deploy Message`**: Latest deployment message or error details.
- **`Last Deploy Run URL`**: GitHub Actions URL for the latest deployment dispatch.

### Actions
- **`Create Workflow Template`**: Creates/updates workflow category and template in standard BC workflow.
- **`Generate Code`**: Generates AL page extension and opens code editor.
- **`Auto Deploy Scheduler`**: Opens deployment scheduler for instant/scheduled publishing.
- **`Open Last Deploy Run`**: Opens GitHub Actions workflow page for monitoring.

---

## Detailed Explanation of Setup Page Actions

### Create Workflow Template
**Purpose**: Registers the configured approval workflow as a reusable template in standard Business Central Workflow tables.

**Behavior**:
1. Validates that Table No., Status Field No., and Workflow Category Code are configured
2. Creates or updates `Workflow Category` record with the specified code and description
3. Creates or updates `Workflow` record with template flag enabled
4. Sets workflow description and marks as template for reuse
5. Displays success message with workflow code

**Integration**: Templates appear in `Workflow Templates` page and can be enabled per company.

### Generate Code
**Purpose**: Generates AL page extension code based on the metadata configuration.

**Behavior**:
1. Validates Card Page ID and Status Field No. are configured
2. Calls `AL Page Extension Generator.GeneratePageExtension()` with next available object ID
3. Saves generated AL text to `Generated AL Text` blob field
4. Updates `Last Generated File Name` with suggested filename
5. Opens `Code Editor Workflow AL` page for review
6. Creates audit entry in `Custom Approval Wf Gen Lines` table

**Output**: Complete page extension AL with approval actions, status handling, and workflow integration.

### Auto Deploy Scheduler
**Purpose**: Provides instant or scheduled deployment options for generated extensions.

**Behavior**:
1. Opens `Auto Deploy Scheduler` page pre-populated with setup context
2. Supports immediate deployment or scheduled execution
3. Configures GitHub Actions workflow dispatch parameters
4. Monitors deployment status and provides run URL links

**Integration**: Uses `WF Deploy Scheduler Mgt.` for orchestration.

### Open Last Deploy Run
**Purpose**: Provides direct access to deployment monitoring in GitHub Actions.

**Behavior**:
1. Opens browser to the `Last Deploy Run URL` stored in setup
2. Only available when a deployment has been executed
3. Enables real-time monitoring of deployment progress

---

## Code Editor Purpose

The `Code Editor Workflow AL` page (80114) serves as the primary interface for reviewing, managing, and deploying generated AL code:

### Core Functionality
- **AL Code Preview**: Read-only display of generated page extension source code
- **File Management**: Shows suggested filename and character count
- **Code Actions**: Download, reset, auto-deploy, and schedule options
- **Integration Hub**: Connects code generation with deployment orchestration

### User Workflow
1. **Review**: Examine generated AL for correctness and customization needs
2. **Download**: Export AL file for manual packaging or external development
3. **Reset**: Clear generated code to regenerate with updated configuration
4. **Deploy**: Trigger automated deployment workflows

### Technical Implementation
- Uses `Custom Approval Workflow Setup`.`Generated AL Text` blob for storage
- Integrates with deployment scheduler for seamless workflow
- Provides audit trail through generation lines table

---

## Deployment Scheduler

The `Auto Deploy Scheduler` page (80115) manages the deployment lifecycle of generated extensions:

### Key Features
- **Instant Deploy**: Immediate execution of deployment workflow
- **Scheduled Deploy**: Deferred execution with configurable timing
- **Job Monitoring**: Real-time status tracking and error reporting
- **GitHub Integration**: Workflow dispatch to external CI/CD pipelines

### Configuration Fields
- **Earliest Start Date/Time**: When scheduled deployment should execute
- **Job Timeout**: Maximum execution time before cancellation
- **Deploy Status**: Current state (None, Scheduled, Queued, Success, Failed)
- **Run URL**: Direct link to GitHub Actions workflow run

### Deployment Flow
1. **Setup**: Configure repository, branch, workflow file, and PAT token
2. **Schedule**: Set execution parameters and timing
3. **Execute**: Trigger GitHub Actions workflow dispatch
4. **Monitor**: Track progress and handle failures
5. **Complete**: Update status and provide run URL for verification

---

## Workflow Template Registration Behavior

### Template Creation Process
1. **Validation**: Ensures required fields (Table No., Status Field No., Workflow Category) are configured
2. **Category Management**: Creates/updates `Workflow Category` with code and description
3. **Template Registration**: Creates `Workflow` record with:
   - Template flag enabled
   - Description from setup
   - Category linkage
   - Placeholder for workflow steps

### Standard Workflow Integration
- **Template Visibility**: Appears in `Workflow Templates` page for company-wide configuration
- **Step Configuration**: Functional consultants can add workflow steps (When/Then conditions)
- **Activation**: Templates can be enabled/disabled per company
- **Reuse**: Single template supports multiple companies with different step configurations

### Runtime Behavior
- **Event Handling**: Templates respond to standard workflow events
- **Approval Routing**: Supports standard approval entry creation and routing
- **Status Integration**: Coordinates with generated page extension status updates

---

## Standard Workflow Creation Flow

### Workflow Template Setup
1. **Access Templates**: Navigate to `Workflow Templates` page
2. **Select Template**: Choose generated template by code/description
3. **Enable Workflow**: Set `Enabled` = Yes for the company
4. **Configure Steps**: Add workflow steps with conditions and responses

### Workflow Step Configuration
- **When Conditions**: Define triggers (e.g., "Approval Request is Sent")
- **Then Responses**: Define actions (e.g., "Create Approval Entry", "Send Notification")
- **Approver Setup**: Configure approval routing rules
- **Notification Setup**: Define email/SMTP notifications

### Workflow Activation
- **Validation**: System validates step configuration
- **Activation**: Workflow becomes active for the company
- **Testing**: Functional testing of approval flows
- **Monitoring**: Review workflow instances in `Workflows` page

---

## Workflow Enablement

### Template Enablement
- **Company Scope**: Templates are enabled per company
- **Version Control**: Multiple versions can coexist
- **Conditional Logic**: Supports complex approval routing

### Runtime Enablement
- **Event Detection**: Workflows trigger on configured events
- **Condition Evaluation**: When conditions must be met
- **Response Execution**: Then responses execute in sequence
- **Error Handling**: Failed steps logged and workflow continues

### Integration Points
- **Approval Entries**: Automatic creation on workflow trigger
- **Notifications**: Email/SMTP integration for stakeholders
- **Status Updates**: Coordination with page extension status changes

---

## Runtime Approval Behavior

### Approval Action Visibility
- **Permission Check**: `HasOpenApprovalEntriesForCurrentUser()` determines visibility
- **User Context**: Only shows for current user as approver
- **Status Context**: Only visible when record is in pending state

### Approval Processing
- **Entry Validation**: Verifies user has open approval entry
- **Status Update**: Updates approval entry status (Approved/Rejected)
- **Record Update**: Modifies record status based on setup configuration
- **Workflow Continuation**: Triggers next workflow steps if configured

### Multi-Approver Support
- **Sequential Approval**: Supports approval chains
- **Parallel Approval**: Multiple approvers can act simultaneously
- **Completion Logic**: Configurable completion rules (All, Any, Majority)

---

## Record Restriction Logic

### Approval State Restrictions
- **Send Restrictions**: Only allowed when status matches "Send Approval When"
- **Cancel Restrictions**: Only allowed when status matches "Cancel Approval When"
- **Action Restrictions**: Approve/Reject only visible for pending records with user approval entries

### User Permission Logic
- **Approver Validation**: Checks `Approval Entry` table for user access
- **Role-Based Access**: Integrates with standard BC permission system
- **Record-Level Security**: Respects table-level permissions

### Status Transition Validation
- **Valid Transitions**: Only allows configured status changes
- **Business Logic**: Prevents invalid state combinations
- **Audit Trail**: Logs all status changes for compliance

---

## Status Transitions

### Configured Transitions
- **Send Approval**: `Send Approval When` → `On Pending Document`
- **Cancel Approval**: `Cancel Approval When` → `On Open Document`
- **Approve**: `On Pending Document` → `On Approve Document`
- **Reject**: `On Pending Document` → `On Reject Document`
- **Release**: Manual transition to `On Release Document`

### Transition Logic
- **Field Updates**: Uses RecordRef to update configured status fields
- **Validation**: Ensures current status allows transition
- **Persistence**: Commits changes immediately
- **Notification**: Provides user feedback on successful transitions

### Integration with Workflow
- **Event Triggers**: Status changes can trigger workflow events
- **Conditional Logic**: Workflow steps can depend on status values
- **Audit Logging**: All transitions recorded for compliance

---

## Approval Cancellation

### Cancellation Process
1. **Validation**: Verifies user has permission to cancel
2. **Entry Update**: Sets approval entry status to Cancelled
3. **Status Revert**: Changes record status back to open state
4. **Workflow Notification**: Triggers cancellation workflow events

### Cancellation Logic
- **Permission Check**: Only requestor or administrator can cancel
- **State Validation**: Only pending approvals can be cancelled
- **Cascade Effects**: Cancels all related approval entries
- **Notification**: Informs affected stakeholders

### Integration Points
- **Workflow Events**: `APPROVAL_REQUEST_CANCELLED` event
- **Audit Trail**: Logs cancellation with reason
- **Status Reset**: Reverts to pre-approval state

---

## Completion and Rejection Handling

### Approval Completion
- **Entry Processing**: Updates all approval entries to Approved
- **Status Update**: Sets record to approved/released status
- **Workflow Continuation**: Triggers completion events
- **Notification**: Sends completion notifications

### Rejection Handling
- **Entry Processing**: Updates approval entries to Rejected
- **Status Update**: Sets record to rejected status
- **Workflow Termination**: Stops workflow execution
- **Notification**: Sends rejection notifications with reasons

### Post-Processing
- **Audit Logging**: Records completion/rejection details
- **Cleanup**: Removes temporary workflow data
- **Archiving**: Moves completed workflows to history

---

## Full Functional and Non-Functional Requirements

### Functional Requirements

#### Configuration Management
- FR1: Users can configure approval workflows for any table with status fields
- FR2: System validates configuration completeness before code generation
- FR3: Generated code includes all configured approval actions and status handling
- FR4: Workflow templates are registered in standard BC workflow tables

#### Code Generation
- FR5: Generated AL compiles without errors
- FR6: Generated code uses RecordRef for table-agnostic operations
- FR7: Approval actions appear on configured card pages
- FR8: Status transitions follow configured mappings

#### Deployment Management
- FR9: Instant deployment triggers immediate publishing
- FR10: Scheduled deployment supports deferred execution
- FR11: Deployment status is tracked and reported
- FR12: GitHub Actions integration for CI/CD pipelines

#### Runtime Behavior
- FR13: Approval actions are visible based on user permissions
- FR14: Status updates occur automatically on approval actions
- FR15: Workflow events are triggered for standard integration
- FR16: Approval entries are managed using standard BC tables

#### Workflow Integration
- FR17: Templates appear in standard workflow UI
- FR18: Workflows can be enabled/disabled per company
- FR19: Workflow steps support standard approval routing
- FR20: Notifications integrate with standard BC notification system

### Non-Functional Requirements

#### Performance
- NFR1: Code generation completes within 5 seconds
- NFR2: Page load times remain under 2 seconds
- NFR3: Approval actions process within 1 second
- NFR4: Status updates are immediate and synchronous

#### Scalability
- NFR5: Supports unlimited custom tables and pages
- NFR6: Handles high-volume approval processing
- NFR7: Scales with standard BC workflow engine limitations

#### Usability
- NFR8: Setup page provides clear field labels and tooltips
- NFR9: Error messages are descriptive and actionable
- NFR10: Generated code is readable and follows AL best practices

#### Security
- NFR11: Respects standard BC permission system
- NFR12: Approval actions validate user access
- NFR13: Generated code doesn't bypass security controls

#### Reliability
- NFR14: All AL code compiles successfully
- NFR15: Error handling prevents system crashes
- NFR16: Data integrity maintained during status transitions

#### Maintainability
- NFR17: Code follows AL development best practices
- NFR18: Object numbering follows consistent strategy
- NFR19: Documentation is comprehensive and up-to-date

---

## Technical Architecture

### System Components

#### Data Layer
- **Custom Tables**: Store configuration metadata and generated artifacts
- **Standard Tables**: Leverage BC workflow and approval tables
- **Blob Storage**: Store generated AL source code

#### Business Logic Layer
- **Codeunits**: Handle generation, deployment, and approval processing
- **Workflow Integration**: Interface with standard BC workflow engine
- **Validation Logic**: Ensure configuration and runtime integrity

#### Presentation Layer
- **Setup Pages**: Configuration and management interfaces
- **Generated Extensions**: Runtime approval UI components
- **Monitoring Pages**: Deployment and workflow status displays

### Integration Architecture

#### Internal Integration
- **AL Objects**: Seamless integration between custom and standard objects
- **Event System**: Workflow events trigger approval processing
- **Data Flow**: Configuration drives code generation and deployment

#### External Integration
- **GitHub Actions**: CI/CD pipeline integration
- **BC Admin Center**: SaaS deployment management
- **PowerShell**: OnPrem deployment automation

### Deployment Architecture

#### SaaS Deployment
- **GitHub Dispatch**: Triggers cloud-based publishing
- **BC SaaS APIs**: Automated tenant publishing
- **Monitoring**: Real-time deployment status tracking

#### OnPrem Deployment
- **PowerShell Scripts**: Local publishing automation
- **BC Administration**: Server-based deployment
- **File System**: AL file management and packaging

---

## Framework Architecture

### Core Framework Components

#### Configuration Framework
- **Setup Table**: Central configuration repository
- **Validation Engine**: Ensures configuration completeness
- **Metadata Resolver**: Resolves table and field information

#### Generation Framework
- **Template Engine**: AL code generation with placeholders
- **Object ID Management**: Automatic object numbering
- **Code Validation**: Compilation checking and error reporting

#### Deployment Framework
- **Scheduler Engine**: Instant and scheduled deployment
- **GitHub Integration**: Workflow dispatch management
- **Status Tracking**: Deployment monitoring and reporting

#### Runtime Framework
- **Approval Engine**: Generic approval processing
- **Status Engine**: Field-based status management
- **Workflow Bridge**: Standard workflow integration

### Framework Patterns

#### Metadata-Driven Design
- Configuration controls all generated artifacts
- Template-based code generation
- Dynamic field and table resolution

#### Generic Processing
- RecordRef-based table operations
- FieldRef-based field manipulation
- Type-safe enum handling

#### Event-Driven Architecture
- Workflow event integration
- Status change notifications
- Deployment lifecycle events

---

## Generated Code Architecture

### Code Structure

#### Page Extension Template
```
pageextension [ID] "[Name]" extends [CardPage]
{
    actions
    {
        addlast(Processing)
        {
            group(RequestApproval)
            {
                // Send/Cancel actions with status conditions
            }
            group(Approval)
            {
                // Approve/Reject actions with visibility conditions
            }
        }
    }
    
    var
        // Global variables for approval state
        WfMgt: Codeunit "Custom Approval Workflow Mgt.";
        
    trigger OnAfterGetCurrRecord()
    begin
        // Check approval entries for current user
    end;
}
```

#### Action Implementation
- **SendApprovalRequest**: Calls `WfMgt.SendApprovalRequest(RecRef)`
- **CancelApprovalRequest**: Calls `WfMgt.CancelApprovalRequest(RecRef)`
- **Approve**: Calls `WfMgt.ApproveRecord(RecRef)`
- **Reject**: Calls `WfMgt.RejectRecord(RecRef)`

#### Status Handling
- Uses RecordRef.Field() for dynamic field access
- Validates current status before transitions
- Updates status based on configuration mappings

#### Workflow Integration
- Triggers standard workflow events
- Integrates with approval entry management
- Supports generic table operations

### Code Quality Standards

#### AL Best Practices
- Proper object numbering and naming
- Consistent code formatting
- Error handling and validation
- Performance optimization

#### Maintainability
- Clear variable naming
- Comprehensive comments
- Modular code structure
- Separation of concerns

---

## Clear Separation of Framework vs Generated Objects

### Framework Objects (Permanent)
These objects are part of the core solution and are not regenerated:

#### Tables
- `Custom Approval Workflow Setup` (80102)
- `Custom Approval Wf Gen Line` (80103)

#### Pages
- `Custom Approval Workflow` (80112)
- `Custom Approval Workflow List` (80119)
- `Custom Approval Wf Gen Lines` (80113)
- `Code Editor Workflow AL` (80114)
- `Auto Deploy Scheduler` (80115)

#### Codeunits
- `Workflow Template Builder` (80122)
- `AL Page Extension Generator` (80140)
- `Custom Approval Workflow Mgt.` (80120)
- `WF Deploy Scheduler Mgt` (80147)
- `WF Deploy Job Runner` (80148)
- `WF Nav Auto Deploy` (80149)

### Generated Objects (Dynamic)
These objects are created by the framework based on configuration:

#### Page Extensions
- Generated AL source code for approval UI
- Object IDs assigned dynamically (80000+ range)
- Include approval actions and status handling

#### Workflow Templates
- Registered in standard `Workflow` table
- Marked as templates for reuse
- Include basic structure for customization

### Runtime Artifacts
- Approval entries in standard tables
- Workflow instances in standard tables
- Status changes on target records
- Deployment logs and audit trails

---

## Required Custom Tables

### Custom Approval Workflow Setup (80102)
```al
table 80102 "Custom Approval Workflow Setup"
{
    fields
    {
        field(1; "No."; Code[20]) { }
        field(2; "Table No."; Integer) { }
        field(3; "Table Name"; Text[280]) { }
        field(4; Enabled; Boolean) { }
        field(10; "Status Field No."; Integer) { }
        field(11; "Status Field Name"; Text[30]) { }
        field(12; "Send Approval When"; Enum "WFDemo Status") { }
        field(13; "Cancel Approval When"; Enum "WFDemo Status") { }
        field(14; "On Open Document"; Enum "WFDemo Status") { }
        field(15; "On Pending Document"; Enum "WFDemo Status") { }
        field(16; "On Approve Document"; Enum "WFDemo Status") { }
        field(17; "On Reject Document"; Enum "WFDemo Status") { }
        field(18; "On Release Document"; Enum "WFDemo Status") { }
        field(20; "Document No. Field No."; Integer) { }
        field(21; "Document No. Field Name"; Text[30]) { }
        field(22; "Card Page ID"; Integer) { }
        field(23; "Card Page Name"; Text[280]) { }
        field(30; "Workflow Category Code"; Code[20]) { }
        field(31; "Workflow Category Description"; Text[100]) { }
        field(32; "Workflow Code"; Code[20]) { }
        field(33; "Workflow Description"; Text[100]) { }
        field(40; "Generated AL Text"; Blob) { }
        field(41; "Last Generated File Name"; Text[250]) { }
        field(50; "Deploy Repo Owner"; Text[100]) { }
        field(51; "Deploy Repo Name"; Text[100]) { }
        field(52; "Deploy Branch"; Text[100]) { }
        field(53; "Deploy Workflow File"; Text[100]) { }
        field(54; "Deploy PAT Token"; Text[100]) { }
        field(60; "Last Scheduled At"; DateTime) { }
        field(61; "Last Deploy At"; DateTime) { }
        field(62; "Last Deploy Status"; Option) { }
        field(63; "Last Deploy Message"; Text[250]) { }
        field(64; "Last Deploy Run URL"; Text[500]) { }
    }
}
```

### Custom Approval Wf Gen Line (80103)
```al
table 80103 "Custom Approval Wf Gen Line"
{
    fields
    {
        field(1; "Setup No."; Code[20]) { }
        field(2; "Line No."; Integer) { }
        field(3; Name; Text[50]) { }
        field(4; "File Extension"; Text[10]) { }
        field(5; "Generated DateTime"; DateTime) { }
    }
}
```

---

## Required Custom Pages

### Custom Approval Workflow (80112)
- **Purpose**: Main configuration interface
- **Layout**: Grouped fields for General, Status, Document, Workflow, Deployment
- **Actions**: Generate Code, Create Workflow Template, Auto Deploy Scheduler

### Code Editor Workflow AL (80114)
- **Purpose**: AL code review and management
- **Layout**: AL text display, file info, character count
- **Actions**: Download, Reset, AutoDeploy, Schedule

### Auto Deploy Scheduler (80115)
- **Purpose**: Deployment orchestration
- **Layout**: Scheduling controls, status monitoring
- **Actions**: Instant Deploy, Schedule Deploy

---

## Required Custom Codeunits

### AL Page Extension Generator (80140)
**Responsibilities**:
- Generate AL page extension source code
- Handle template substitution with metadata
- Validate generated code syntax
- Save generated code to setup record

### Custom Approval Workflow Mgt. (80120)
**Responsibilities**:
- Handle approval actions (Send/Cancel/Approve/Reject)
- Manage status transitions using RecordRef
- Integrate with standard workflow events
- Validate user permissions and approval entries

### Workflow Template Builder (80122)
**Responsibilities**:
- Create/update workflow categories
- Register workflow templates in standard tables
- Set template flags and descriptions
- Bootstrap basic workflow structure

### WF Deploy Scheduler Mgt (80147)
**Responsibilities**:
- Orchestrate instant and scheduled deployments
- Manage GitHub Actions workflow dispatch
- Track deployment status and URLs
- Handle deployment timeouts and errors

---

## Required Page Extensions

### Generated Page Extensions
- **Object Range**: 80000-89999 (configurable)
- **Naming Pattern**: `[TableName] Approval`
- **Content**: Approval actions, status handling, workflow integration

### Role Center Extensions
- **Purpose**: Add setup pages to relevant role centers
- **Targets**: Business Manager, Order Processor role centers
- **Actions**: Quick access to workflow setup and monitoring

---

## Workflow Integration Components

### Standard BC Integration
- **Workflow Management**: `Codeunit "Workflow Management"`
- **Approval Entry**: Standard approval tracking table
- **Workflow Tables**: Category, Workflow, Workflow Step tables

### Custom Integration Layer
- **Event Handling**: Generic workflow event triggers
- **Status Coordination**: Synchronize with workflow state
- **Approval Routing**: Interface with standard approval system

### Runtime Integration
- **Event Triggers**: Send/Cancel approval events
- **Status Updates**: Coordinate with workflow state changes
- **Entry Management**: Create/update approval entries

---

## Deployment Management Components

### Scheduler Components
- **Auto Deploy Scheduler**: User interface for deployment
- **WF Deploy Scheduler Mgt**: Business logic for scheduling
- **WF Deploy Job Runner**: Background job execution

### GitHub Integration
- **Workflow Dispatch**: API calls to trigger GitHub Actions
- **Status Monitoring**: Track deployment progress
- **Error Handling**: Report deployment failures

### OnPrem Components
- **PowerShell Integration**: Local deployment scripts
- **File Management**: AL file export and packaging
- **BC Admin Integration**: Server deployment APIs

---

## Logging/Audit Components

### Generation Audit
- **Custom Approval Wf Gen Lines**: Track code generation history
- **Timestamp Tracking**: Record generation date/time
- **File Metadata**: Store generated file information

### Deployment Audit
- **Status Fields**: Track deployment state and timing
- **Message Logging**: Store deployment messages and errors
- **URL Tracking**: Maintain links to deployment runs

### Runtime Audit
- **Workflow Logs**: Standard BC workflow instance logging
- **Approval History**: Standard approval entry audit trail
- **Status Change Logs**: Record all status transitions

---

## Suggested Table and Page Structures

### Table Structure Guidelines
- **Primary Key**: Use Code[20] for setup tables, Integer for lines
- **Field Numbering**: 1-9: Keys, 10-99: Core fields, 100+: Extended fields
- **Data Types**: Use appropriate types (Code, Text, Integer, Enum, Blob)
- **Validation**: Include OnValidate triggers for field resolution

### Page Structure Guidelines
- **Layout**: Use grouped layout with clear sections
- **Field Groups**: General, Configuration, Status, Monitoring
- **Actions**: Primary actions in main group, secondary in dropdown
- **FactBoxes**: Show related information and generated lines

### Page Extension Structure
- **Placement**: Add approval actions to Processing > RequestApproval/Approval
- **Visibility**: Use Visible property for permission-based display
- **Triggers**: OnAfterGetCurrRecord for dynamic visibility updates

---

## Codeunit Responsibilities

### AL Page Extension Generator
- **Input**: Setup record with metadata
- **Process**: Template-based code generation
- **Output**: Valid AL source code
- **Validation**: Syntax checking and error reporting

### Custom Approval Workflow Mgt.
- **Input**: RecordRef and action type
- **Process**: Generic approval processing
- **Output**: Status updates and workflow events
- **Validation**: Permission and state checking

### Workflow Template Builder
- **Input**: Setup metadata
- **Process**: Standard table updates
- **Output**: Registered workflow templates
- **Validation**: Required field checking

### WF Deploy Scheduler Mgt
- **Input**: Deployment parameters
- **Process**: GitHub Actions integration
- **Output**: Deployment status and URLs
- **Validation**: Configuration completeness

---

## Object Numbering Strategy

### Range Allocation
- **80000-80199**: Core framework objects (tables, pages, codeunits)
- **80200-80399**: Extended framework objects
- **80400-89999**: Generated page extensions (configurable)
- **90000-99999**: Reserved for future extensions

### Specific Assignments
- **Tables**: 80100-80199
- **Pages**: 80100-80199  
- **Codeunits**: 80100-80199
- **Enums**: 80100-80199
- **Page Extensions**: 80000+ (dynamic)

### Naming Convention
- **Prefix**: Use descriptive prefixes (Custom Approval, WF, AL)
- **Suffix**: Use type indicators (Setup, Mgt, Generator)
- **Consistency**: Maintain naming patterns across objects

---

## Naming Conventions

### Object Names
- **Tables**: `[Prefix] [Entity] [Type]` (e.g., "Custom Approval Workflow Setup")
- **Pages**: `[Entity] [Type]` (e.g., "Custom Approval Workflow")
- **Codeunits**: `[Entity] [Purpose]` (e.g., "AL Page Extension Generator")

### Field Names
- **Primary Keys**: "No.", "Code", "Line No."
- **Descriptive**: Use full words, avoid abbreviations
- **Consistent**: Use same terms across related objects

### Variable Names
- **AL Standard**: CamelCase for variables, PascalCase for procedures
- **Descriptive**: Use meaningful names (Setup, RecRef, StatusField)
- **Prefixes**: Use type prefixes (Rec, Temp, Local)

### File Names
- **Generated AL**: `PageExt[ID].al`
- **Documentation**: `Solution Design.md`
- **Scripts**: Descriptive names with purpose

This comprehensive documentation provides complete coverage of the Custom Approval Workflow Generator solution architecture, implementation details, and operational behavior.

---

## Solution Overview

### Core capabilities

- Metadata-driven setup page for workflow configuration.
- Template-based AL generation for page extensions and approval logic.
- Code editor preview and management for generated AL.
- Workflow template creation and registration in standard Workflow tables.
- Deployment orchestration using Instant Deploy and Schedule Deploy actions.
- Support for GitHub Actions-style dispatch workflows and BC Admin Center integration.

### Primary user personas

- Solution Architect: validates design and extension packaging.
- Functional Consultant: configures approval workflow for custom documents.
- AL Developer: reviews generated AL, customizes and packages extensions.
- Implementation Lead: coordinates deployment and production rollout.

---

## Functional Design

### Setup page / primary configuration

The main configuration page is `Custom Approval Workflow` (page `80112`). It exposes the following groups:

- General
  - `No.`
  - `Table No.`
  - `Table Name`
  - `Enabled`
- Status Configuration
  - `Status Field No.`
  - `Status Field Name`
  - `Send Approval When`
  - `Cancel Approval When`
  - `On Open Document`
  - `On Pending Document`
  - `On Approve Document`
  - `On Reject Document`
  - `On Release Document`
- Document Configuration
  - `Document No. Field No.`
  - `Document No. Field Name`
  - `Card Page ID`
  - `Card Page Name`
- Workflow Configuration
  - `Workflow Category Code`
  - `Workflow Category Description`
  - `Workflow Code`
  - `Workflow Description`
- Deployment Configuration
  - `Deploy Repo Owner`
  - `Deploy Repo Name`
  - `Deploy Branch`
  - `Deploy Workflow File`
  - `Deploy PAT Token`
- Deployment Monitoring
  - `Last Scheduled At`
  - `Last Deploy At`
  - `Last Deploy Status`
  - `Last Deploy Message`
  - `Last Deploy Run URL`

A dedicated factbox part displays generated page extension metadata via `Custom Approval Wf Gen Lines`.

### Key actions and experience

- `Create Workflow Template`
  - Creates / updates `Workflow Category` and `Workflow` records.
  - Marks the workflow as a template.
  - Preserves standard BC Workflow semantics.

- `Generate Code`
  - Generates page extension AL using the metadata.
  - Saves generated AL text to the setup record blob.
  - Opens the code editor page for review.

- `Auto Deploy Scheduler`
  - Opens the deployment scheduler page.
  - Supports instant or deferred deployment.

- `Open Last Deploy Run`
  - Opens the latest deployment run URL in GitHub Actions.

### Code editor and generated AL management

`Code Editor Workflow AL` (page `80114`) provides:

- Read-only preview of generated AL source.
- Suggested file name display.
- Character count for generated text.
- Actions:
  - `Download AL File`
  - `Reset Code`
  - `AutoDeploy Setup`
  - `Schedule Deployment`
  - `Clear Text`

This page is the primary review and handoff point for generated code.

### Deployment scheduling

`Auto Deploy Scheduler` (page `80115`) supports:

- `Instant Deploy`
- `Earliest Start Date/Time`
- `Job Timeout`
- `Schedule`
- `Deploy`

It is built to support a GitHub Actions dispatch-based deployment workflow, making it suitable for SaaS or cloud-hosted deployment pipelines where API-driven publish is available.

---

## Technical Architecture

### Object model

- Tables
  - `Custom Approval Workflow Setup` (`80102`)
  - `Custom Approval Wf Gen Line` (`80103`)
  - Supporting objects: `Workflow Demo Setup`, `Approval Testing`, `NoCode_*`
- Pages
  - `Custom Approval Workflow` (`80112`)
  - `Custom Approval Workflow List` (`80119`)
  - `Custom Approval Wf Gen Lines` (`80113`)
  - `Code Editor Workflow AL` (`80114`)
  - `Auto Deploy Scheduler` (`80115`)
  - Supporting UX pages and role center extensions
- Codeunits
  - `Workflow Template Builder` (`80122`)
  - `AL Page Extension Generator` (`80140`?)
  - `Custom Approval Workflow Mgt.` (`80120`)
  - `WF Deploy Scheduler Mgt` (`80147`)
  - `WF Deploy Job Runner` / `WF Nav Auto Deploy`

### Generation engine workflow

1. User configures a `Custom Approval Workflow Setup` record.
2. `Generate Code` triggers `AL Page Extension Generator`.
3. Engine builds AL with placeholders for:
   - target table and card page
   - document number field
   - status field mappings
   - approval actions and page action bindings
   - standard Business Central workflow approvals
4. Generated AL is saved to the setup blob and the last file name is recorded.
5. User reviews and downloads code from `Code Editor Workflow AL`.
6. Workflow template can be created in standard BC `Workflow` objects.

### Workflow template registration

`Workflow Template Builder` handles:

- Category creation or update.
- Workflow header creation / update.
- Template flagging.
- Conditional workflow step bootstrapping for sample approval flows.

This ensures the generated configuration is surfaced in the BC Workflow UI and usable by standard workflow activation.

### Deployment pipeline

Deployment is orchestrated by `WF Deploy Scheduler Mgt` and supporting pages/codeunits.

- `Instant Deploy` triggers `RunDeployNow()`.
- `Schedule` triggers `ScheduleDeploy()` with `EarliestStart` and `JobTimeout`.
- The deploy engine builds a runtime dispatch URL and maintains status fields.

This pattern fits both:

- Cloud / SaaS: use GitHub Actions or Azure DevOps pipeline dispatch from BC.
- OnPrem: the page and scheduler can still record deployment metadata; actual deployment step should be adapted to local publishing or BC administration APIs.

---

## SaaS vs OnPrem Considerations

### SaaS

- Use GitHub Actions / Azure DevOps to publish to the tenant.
- Deployment action should call BC SaaS Admin Center APIs or existing pipeline webhooks.
- PAT token should be secured and used only for workflow dispatch.
- Generated AL file download is essential for packaging outside BC.

### OnPrem

- The same metadata-driven generation model applies.
- Deployment scheduler can be repurposed for local publish automation or custom PowerShell-based publish jobs.
- If no external dispatch pipeline exists, the user can export the generated AL and package it locally.
- For OnPrem, consider adding a `Local Publish` action and a `Publish Package` integration with `NAV` or `Business Central Administration` APIs.

---

## User Journey

1. Create a new entry in `Custom Approval Workflow`.
2. Select `Table No.`, `Table Name`, and `Status Field No.`.
3. Configure document number and card page target.
4. Define workflow metadata and approval status mappings.
5. Generate page extension AL with `Generate Code`.
6. Review generated source in `Code Editor Workflow AL`.
7. Download AL file for packaging or continue to auto deployment.
8. Create a workflow template using `Create Workflow Template`.
9. Schedule or run deployment from `Auto Deploy Scheduler`.
10. Monitor deployment status and open last run URL.

---

## Acceptance Criteria

- [x] Users can define a custom approval workflow for an existing table and page.
- [x] The solution stores metadata for table ID, page ID, document number, and status mappings.
- [x] Generated AL source is previewed and downloadable.
- [x] Workflow templates are created in standard BC workflow objects.
- [x] Deployment supports instant and scheduled publish flows.
- [x] The solution is documented as a scaffolding engine, not a pure no-code system.

---

## Implementation Notes

- Generated AL is persisted in `Custom Approval Workflow Setup`.`Generated AL Text` blob.
- Temporary setup numbers are replaced using `No. Series` after field selection.
- `Table Metadata` and `Field` records resolve target table/page names.
- `Workflow Template Builder` intentionally disables workflow activation until configured.
- Approval actions are handled by `Custom Approval Workflow Mgt.` and page extension actions.

---

## Recommended Enhancements

- Add `SaaS vs OnPrem` deployment strategy guidance in the UI or documentation.
- Add validation to prevent workflow creation without a selected table, card page, and status field.
- Extend code generation to support `List` page extensions and custom approval actions on list pages.
- Add a `Generate Workflow Steps` option to bootstrap `When Event / Then Response` steps for common approval patterns.
- Add audit history for generated deployments and workflow template changes.

---

## Object Reference

| Object | Type | Purpose |
|---|---|---|
| `Custom Approval Workflow Setup` | Table | Stores metadata-driven workflow configuration |
| `Custom Approval Wf Gen Line` | Table | Stores generated page extension lines and metadata |
| `Custom Approval Workflow` | Page | Setup UI with actions and deployment monitoring |
| `Code Editor Workflow AL` | Page | AL preview, download, reset, and deploy actions |
| `Auto Deploy Scheduler` | Page | Deployment scheduling and instant deploy UI |
| `Workflow Template Builder` | Codeunit | Creates/updates standard workflow templates |
| `AL Page Extension Generator` | Codeunit | Generates AL page extension source text |
| `WF Deploy Scheduler Mgt` | Codeunit | Orchestrates scheduled/instant deployment |
| `Custom Approval Workflow Mgt.` | Codeunit | Approval action handlers and UI bootstrapping |

---

## Status Transition Matrix

### Configurable Status Transitions

| Current Status | Action | New Status | Conditions | Workflow Event |
|---|---|---|---|---|
| `Send Approval When` (e.g., Open) | Send Approval Request | `On Pending Document` (e.g., Pending) | User has send permission | APPROVAL_REQUEST_SENT |
| `Cancel Approval When` (e.g., Pending) | Cancel Approval Request | `On Open Document` (e.g., Open) | User has cancel permission | APPROVAL_REQUEST_CANCELLED |
| `On Pending Document` (e.g., Pending) | Approve | `On Approve Document` (e.g., Approved) | User has open approval entry | APPROVAL_REQUEST_APPROVED |
| `On Pending Document` (e.g., Pending) | Reject | `On Reject Document` (e.g., Rejected) | User has open approval entry | APPROVAL_REQUEST_REJECTED |
| Any Status | Manual Release | `On Release Document` (e.g., Released) | Business logic allows | WORKFLOW_COMPLETED |

### Transition Validation Rules

- **Forward Only**: Cannot revert from Approved/Rejected to Pending
- **Permission Based**: Only authorized users can trigger transitions
- **State Dependent**: Actions only available in specific states
- **Workflow Driven**: Transitions can be blocked by active workflow rules

---

## Workflow Event Names

### Standard Business Central Workflow Events

| Event Name | Trigger | Description |
|---|---|---|
| `APPROVAL_REQUEST_SENT` | SendApprovalRequest action | Fired when approval request is submitted |
| `APPROVAL_REQUEST_CANCELLED` | CancelApprovalRequest action | Fired when approval request is cancelled |
| `APPROVAL_REQUEST_APPROVED` | Approve action | Fired when approval entry is approved |
| `APPROVAL_REQUEST_REJECTED` | Reject action | Fired when approval entry is rejected |
| `WORKFLOW_COMPLETED` | Final approval/rejection | Fired when workflow reaches completion |

### Custom Integration Events

| Event Name | Trigger | Description |
|---|---|---|
| `CUSTOM_APPROVAL_STATUS_CHANGED` | Status field update | Fired on any status transition |
| `CUSTOM_APPROVAL_WORKFLOW_CREATED` | Template registration | Fired when workflow template is created |
| `CUSTOM_APPROVAL_CODE_GENERATED` | Code generation | Fired when AL code is generated |

---

## Workflow Response Chain

### Sequential Response Execution

1. **Event Detection**: Workflow Management detects configured event
2. **Condition Evaluation**: When conditions are evaluated
3. **Response Execution**: Then responses execute in sequence:
   - Create Approval Entry
   - Send Notification
   - Update Status Field
   - Execute Custom Codeunit
4. **Completion Check**: Verify all required approvals received
5. **Final Response**: Execute completion actions (approve/reject)

### Response Types Supported

- **Approval Entry Creation**: Standard approval routing
- **Email Notifications**: SMTP-based notifications
- **Status Updates**: Field value changes
- **Codeunit Execution**: Custom business logic
- **Page Updates**: UI refresh triggers

---

## Page Action Logic

### Approval Actions Implementation

#### Send Approval Request
```al
trigger OnAction()
var
    RecRef: RecordRef;
begin
    RecRef.GetTable(Rec);
    WfMgt.SendApprovalRequest(RecRef);
end;
```

#### Cancel Approval Request
```al
trigger OnAction()
var
    RecRef: RecordRef;
begin
    RecRef.GetTable(Rec);
    WfMgt.CancelApprovalRequest(RecRef);
end;
```

#### Approve
```al
trigger OnAction()
var
    RecRef: RecordRef;
begin
    RecRef.GetTable(Rec);
    WfMgt.ApproveRecord(RecRef);
end;
```

#### Reject
```al
trigger OnAction()
var
    RecRef: RecordRef;
begin
    RecRef.GetTable(Rec);
    WfMgt.RejectRecord(RecRef);
end;
```

### Action Enablement Logic

- **Send**: `Rec.Status = Rec.Status::Open` (configurable)
- **Cancel**: `Rec.Status = Rec.Status::Pending` (configurable)
- **Approve/Reject**: `OpenApprovalEntriesExistForCurrUser = true`

---

## Approval Visibility and Enablement Logic

### Visibility Conditions

#### Request Approval Group
- Always visible for users with approval permissions
- Contains Send and Cancel actions

#### Approval Group
- Visible only when: `OpenApprovalEntriesExistForCurrUser`
- Contains Approve and Reject actions

### Enablement Expressions

#### Send Approval Request
```al
Enabled = Rec."Status" = Rec."Status"::Open;  // Configurable
```

#### Cancel Approval Request
```al
Enabled = Rec."Status" = Rec."Status"::Pending;  // Configurable
```

#### Approve/Reject Actions
```al
Visible = OpenApprovalEntriesExistForCurrUser;
Enabled = true;  // Always enabled when visible
```

### Permission Integration

- **Table Permissions**: Standard BC table permissions apply
- **Approval Permissions**: Users must have approval setup
- **Record Permissions**: Respects record-level security

---

## Validation Rules

### Configuration Validation

#### Setup Page Validation
- **Table No.**: Must be valid table with data
- **Status Field No.**: Must exist on target table
- **Card Page ID**: Must be valid page extending target table
- **Workflow Category**: Must exist or be creatable

#### Generation Validation
- **Required Fields**: All mandatory fields must be populated
- **Field Types**: Status field must be enum type
- **Page Compatibility**: Card page must extend correct table

### Runtime Validation

#### Action Validation
- **User Permissions**: Current user must have approval rights
- **Record State**: Record must be in correct status for action
- **Approval Entries**: Open entries must exist for approve/reject

#### Status Validation
- **Valid Transitions**: Only configured transitions allowed
- **Field Access**: Status field must be writable
- **Business Rules**: Custom validation can be added

---

## Error Handling Strategy

### Configuration Errors

#### Field Validation Errors
- **Missing Fields**: Clear error messages for required fields
- **Invalid Values**: Type checking and range validation
- **Dependency Errors**: Check related field consistency

#### Generation Errors
- **Template Errors**: Report AL syntax issues
- **Object ID Conflicts**: Handle duplicate object IDs
- **Compilation Errors**: Validate generated code

### Runtime Errors

#### Approval Processing Errors
- **Permission Errors**: "You do not have permission to approve this record"
- **State Errors**: "Record is not in the correct state for this action"
- **Entry Errors**: "No open approval entry found for current user"

#### Workflow Errors
- **Event Errors**: Log workflow event failures
- **Response Errors**: Handle failed workflow responses
- **Timeout Errors**: Manage long-running workflow operations

### Error Recovery

#### User-Friendly Messages
- **Actionable Errors**: Provide steps to resolve issues
- **Context Information**: Include record and user details
- **Support Information**: Reference documentation or support contacts

#### System Recovery
- **Transaction Rollback**: Maintain data consistency
- **State Recovery**: Revert failed operations
- **Audit Logging**: Record all errors for analysis

---

## Rollback and Recovery Strategy

### Configuration Rollback

#### Setup Changes
- **Field Revert**: Allow reverting individual field changes
- **Complete Reset**: Option to reset entire configuration
- **Version History**: Track configuration changes over time

#### Generated Code Rollback
- **Code Reset**: Clear generated AL and regenerate
- **File Backup**: Maintain backup of previous versions
- **Incremental Updates**: Support partial regeneration

### Runtime Rollback

#### Failed Operations
- **Transaction Scope**: Use database transactions for atomicity
- **State Revert**: Automatically revert status changes on failure
- **Entry Cleanup**: Remove invalid approval entries

#### Deployment Rollback
- **Extension Uninstall**: Remove failed deployments
- **Data Migration**: Handle data changes during rollback
- **Version Control**: Git-based rollback for code changes

### Recovery Procedures

#### Manual Recovery
- **Data Repair**: SQL scripts for data consistency
- **Configuration Restore**: Import backup configurations
- **Workflow Reset**: Recreate failed workflow instances

#### Automated Recovery
- **Health Checks**: Monitor system state
- **Auto-Healing**: Automatic error recovery where possible
- **Alert System**: Notify administrators of issues

---

## Security and Permission Design

### Permission Model

#### Standard BC Permissions
- **Table Permissions**: Read/Write access to setup tables
- **Page Permissions**: Access to configuration pages
- **Codeunit Permissions**: Execute permission for generation codeunits

#### Approval Permissions
- **Approval Setup**: Users must be in approval user setup
- **Workflow Permissions**: Access to workflow configuration
- **Deployment Permissions**: GitHub token and repository access

### Security Controls

#### Data Protection
- **Field Encryption**: Sensitive fields (tokens, credentials)
- **Access Logging**: Audit all configuration changes
- **Data Validation**: Prevent SQL injection and malicious input

#### Runtime Security
- **User Context**: All operations run in user context
- **Permission Checks**: Validate permissions before actions
- **Record Security**: Respect table-level and record-level security

### Role-Based Access

#### Administrator Role
- Full access to all configuration and deployment features
- Can modify system-wide settings
- Access to audit logs and monitoring

#### Developer Role
- Access to code generation and review
- Can download generated AL files
- Limited deployment access

#### Functional Consultant Role
- Configuration access for approval workflows
- Workflow template management
- Read-only access to generated code

---

## SaaS vs OnPrem Feasibility and Restrictions

### SaaS Feasibility

#### Supported Features
- **GitHub Actions Integration**: Full support for cloud CI/CD
- **BC SaaS APIs**: Direct publishing to cloud tenants
- **Automated Deployment**: Instant and scheduled publishing
- **Monitoring**: Real-time deployment status via GitHub

#### Restrictions
- **External Dependencies**: Requires GitHub repository access
- **API Limitations**: Subject to BC SaaS API rate limits
- **Tenant Isolation**: Cannot deploy across multiple tenants
- **Customization Limits**: Some OnPrem features unavailable

### OnPrem Feasibility

#### Supported Features
- **Local Publishing**: Direct BC server deployment
- **PowerShell Automation**: Custom deployment scripts
- **File-Based Deployment**: Manual AL file management
- **Full Control**: Complete server and database access

#### Restrictions
- **Manual Process**: Less automated than SaaS
- **Infrastructure Requirements**: Local BC server setup
- **Security Considerations**: OnPrem security hardening
- **Update Management**: Manual extension updates

### Hybrid Considerations

#### Cross-Environment Deployment
- **Development**: OnPrem for development and testing
- **Production**: SaaS for cloud deployments
- **Migration**: Tools for moving configurations between environments

#### Compatibility Matrix

| Feature | SaaS | OnPrem |
|---|---|---|
| GitHub Actions | ✅ | ⚠️ (Manual) |
| Instant Deploy | ✅ | ✅ |
| Scheduled Deploy | ✅ | ✅ |
| API Publishing | ✅ | ⚠️ (Custom) |
| Monitoring | ✅ | ⚠️ (Custom) |

---

## Governance and Maintainability Considerations

### Governance Framework

#### Change Management
- **Configuration Approval**: Require approval for production changes
- **Version Control**: Git-based versioning for all artifacts
- **Documentation**: Maintain up-to-date technical documentation

#### Quality Assurance
- **Code Reviews**: Review generated AL before deployment
- **Testing**: Automated and manual testing procedures
- **Validation**: Configuration and runtime validation

### Maintainability Practices

#### Code Organization
- **Modular Design**: Separate concerns across codeunits
- **Consistent Naming**: Follow established naming conventions
- **Documentation**: Comprehensive inline and external documentation

#### Update Strategy
- **Backward Compatibility**: Ensure updates don't break existing configurations
- **Migration Scripts**: Provide upgrade paths for new versions
- **Deprecation Policy**: Clear timeline for feature removal

### Monitoring and Support

#### Operational Monitoring
- **Health Checks**: Regular system health validation
- **Performance Monitoring**: Track generation and deployment times
- **Error Tracking**: Centralized error logging and alerting

#### Support Structure
- **Documentation**: User guides and troubleshooting guides
- **Training**: Administrator and developer training programs
- **Support Channels**: Defined escalation paths for issues

---

## Risks and Limitations

### Technical Risks

#### AL Generation Risks
- **Syntax Errors**: Generated code may have compilation issues
- **Runtime Errors**: Generated code may fail in production
- **Performance Issues**: Large generated extensions may impact performance

#### Integration Risks
- **Workflow Conflicts**: Generated workflows may conflict with existing ones
- **Permission Issues**: Generated code may bypass security controls
- **Version Compatibility**: Changes in BC may break generated code

### Business Risks

#### Adoption Risks
- **Learning Curve**: Users need training on configuration
- **Resistance to Change**: Preference for manual development
- **Maintenance Overhead**: Ongoing support for generated code

#### Operational Risks
- **Deployment Failures**: Automated deployment may fail
- **Data Corruption**: Status updates may cause data issues
- **Downtime**: Deployment may require system downtime

### Limitations

#### Functional Limitations
- **Table Types**: Only supports tables with enum status fields
- **Page Types**: Limited to card pages with standard layouts
- **Workflow Complexity**: Cannot handle complex multi-level approvals

#### Technical Limitations
- **Object ID Range**: Limited by available object ID ranges
- **Code Size**: Generated code size may exceed AL limits
- **Performance**: Generic RecordRef operations may be slower

---

## Key Assumptions

### Business Assumptions

#### User Capabilities
- Functional consultants can configure approval workflows
- Developers can review and customize generated AL
- Administrators can manage deployment pipelines

#### Process Assumptions
- Organizations use standard BC approval workflows
- Custom documents follow consistent patterns
- Approval processes are well-defined

### Technical Assumptions

#### Environment Assumptions
- BC version 24.0 or later with AL support
- Access to GitHub for SaaS deployments
- Standard BC security and permission model

#### Integration Assumptions
- Standard workflow and approval tables are available
- Email/SMTP integration is configured
- External systems support required APIs

---

## Edge Cases

### Configuration Edge Cases

#### Unusual Table Structures
- Tables without standard status fields
- Tables with multiple status fields
- Tables with complex relationships

#### Page Layout Variations
- Non-standard page layouts
- Custom page extensions already present
- Mobile-optimized page designs

### Runtime Edge Cases

#### Approval Scenarios
- Multiple approval entries for same record
- Concurrent approval actions
- Approval delegation scenarios

#### Status Transition Edge Cases
- Records stuck in intermediate states
- Status changes outside approval process
- Manual status overrides

### Deployment Edge Cases

#### Environment Variations
- Multi-tenant SaaS deployments
- OnPrem with custom security
- Development vs production differences

#### Failure Scenarios
- Network failures during deployment
- Partial deployment successes
- Rollback complications

---

## UAT Scenarios

### Configuration Testing

#### Basic Configuration
1. Create new approval workflow setup
2. Configure table, status field, and page
3. Generate AL code successfully
4. Verify generated code structure

#### Advanced Configuration
1. Configure complex status mappings
2. Set up workflow category and template
3. Test validation rules
4. Verify error handling

### Generation Testing

#### Code Generation
1. Generate page extension for different table types
2. Verify AL syntax and compilation
3. Test generated action functionality
4. Validate status field handling

#### Template Creation
1. Create workflow templates
2. Verify template registration
3. Test template enablement
4. Validate workflow steps

### Runtime Testing

#### Approval Processing
1. Submit approval requests
2. Test approval/rejection actions
3. Verify status transitions
4. Check notification delivery

#### Workflow Integration
1. Enable workflow templates
2. Test workflow event triggers
3. Verify approval routing
4. Validate completion logic

### Deployment Testing

#### Instant Deployment
1. Trigger instant deployment
2. Monitor deployment progress
3. Verify extension installation
4. Test deployed functionality

#### Scheduled Deployment
1. Schedule future deployment
2. Verify scheduling logic
3. Monitor scheduled execution
4. Validate deployment results

---

## Negative Test Scenarios

### Configuration Errors

#### Invalid Configuration
- Missing required fields
- Invalid table/page references
- Incompatible field types
- Permission violations

#### Generation Failures
- Compilation errors in generated code
- Object ID conflicts
- Template syntax errors
- Resource limitations

### Runtime Errors

#### Permission Issues
- Users without approval rights
- Missing approval entries
- Record access restrictions
- Workflow permission failures

#### State Conflicts
- Invalid status transitions
- Concurrent modification conflicts
- Workflow state inconsistencies
- Data validation failures

### Deployment Failures

#### Environment Issues
- Network connectivity problems
- Authentication failures
- Resource unavailability
- Version compatibility issues

#### Process Failures
- Timeout during deployment
- Partial deployment states
- Rollback complications
- Monitoring failures

---

## Recommended Phased Implementation Plan

### Phase 1: Foundation (Weeks 1-2)

#### Objectives
- Set up development environment
- Implement core framework objects
- Create basic configuration UI

#### Deliverables
- Custom tables and pages
- Basic code generation logic
- Configuration validation

#### Success Criteria
- Framework objects compile successfully
- Basic configuration works
- Code generation produces valid AL

### Phase 2: Core Functionality (Weeks 3-5)

#### Objectives
- Implement AL generation engine
- Add workflow template creation
- Develop approval management logic

#### Deliverables
- Complete code generation
- Workflow integration
- Runtime approval processing

#### Success Criteria
- Generated code compiles and runs
- Workflow templates are created
- Approval actions work correctly

### Phase 3: Deployment & Integration (Weeks 6-7)

#### Objectives
- Implement deployment scheduler
- Add GitHub Actions integration
- Create monitoring and logging

#### Deliverables
- Deployment orchestration
- CI/CD integration
- Monitoring dashboard

#### Success Criteria
- Instant deployment works
- Scheduled deployment functions
- Monitoring provides visibility

### Phase 4: Testing & Documentation (Weeks 8-9)

#### Objectives
- Comprehensive testing
- Documentation completion
- User training materials

#### Deliverables
- Test scenarios and results
- Complete documentation
- Training guides

#### Success Criteria
- All test scenarios pass
- Documentation is complete
- Users can configure and deploy

### Phase 5: Production Deployment (Week 10)

#### Objectives
- Production environment setup
- Go-live preparation
- Post-deployment support

#### Deliverables
- Production deployment
- Go-live checklist
- Support procedures

#### Success Criteria
- Successful production deployment
- Users trained and supported
- System operating correctly

---

## Development Sequence

### Sequence 1: Core Objects
1. Create custom tables (Setup, Gen Lines)
2. Implement basic pages (Setup, List)
3. Add validation logic
4. Create codeunit shells

### Sequence 2: Generation Engine
1. Implement AL Page Extension Generator
2. Add template logic
3. Test code generation
4. Add error handling

### Sequence 3: Workflow Integration
1. Implement Workflow Template Builder
2. Add approval management logic
3. Test workflow creation
4. Validate runtime behavior

### Sequence 4: Deployment System
1. Create deployment scheduler
2. Add GitHub integration
3. Implement monitoring
4. Test deployment flows

### Sequence 5: UI and UX
1. Enhance page layouts
2. Add factboxes and actions
3. Implement role center extensions
4. Polish user experience

---

## Future Enhancements

### Short-term Enhancements (3-6 months)

#### Code Generation Improvements
- Support for list page extensions
- Multiple approval levels
- Custom approval conditions
- Enhanced error reporting

#### Workflow Enhancements
- Advanced routing options
- Approval delegation
- Reminder notifications
- Approval history tracking

#### Deployment Improvements
- Multi-environment support
- Rollback capabilities
- Deployment pipelines
- Integration with Azure DevOps

### Medium-term Enhancements (6-12 months)

#### Advanced Features
- Mobile approval support
- API integration
- Custom approval forms
- Bulk approval operations

#### Analytics and Reporting
- Approval metrics dashboard
- Performance monitoring
- Audit reporting
- Compliance reporting

#### Integration Enhancements
- External system integration
- Third-party approval systems
- Document management integration
- Advanced notification options

### Long-term Vision (12+ months)

#### AI-Powered Features
- Intelligent approval routing
- Predictive approval times
- Automated workflow optimization
- Smart approval recommendations

#### Platform Extensions
- Multi-company support
- Cross-tenant workflows
- Global approval networks
- Advanced analytics platform

---

## Final Architecture Recommendation

### Recommended Architecture Pattern

#### Layered Architecture
```
┌─────────────────┐
│   Presentation  │  Pages, Page Extensions
├─────────────────┤
│   Business      │  Codeunits, Workflow Integration
├─────────────────┤
│   Data          │  Tables, Blob Storage
├─────────────────┤
│   Integration   │  GitHub, BC APIs, External Systems
└─────────────────┘
```

#### Component Distribution
- **Framework Components**: Core objects (80100-80199 range)
- **Generated Components**: Dynamic objects (80000+ range)
- **Integration Components**: External system connections
- **Monitoring Components**: Logging and audit trails

### Scalability Considerations

#### Horizontal Scaling
- Stateless codeunits for load balancing
- Database optimization for large datasets
- Caching for frequently accessed configurations

#### Performance Optimization
- Lazy loading for generated code
- Batch processing for bulk operations
- Asynchronous processing for long-running tasks

### Security Architecture

#### Defense in Depth
- Input validation at all layers
- Permission checks before operations
- Audit logging for all changes
- Encryption for sensitive data

#### Compliance Considerations
- GDPR compliance for user data
- SOX compliance for audit trails
- Industry-specific security standards

---

## Conclusion

The Custom Approval Workflow Generator represents a comprehensive solution for eliminating repetitive approval integration work in Business Central. By providing a metadata-driven framework that generates standardized AL code, registers reusable workflow templates, and orchestrates deployment, it enables organizations to rapidly configure approval workflows for custom documents without manual AL development.

### Key Achievements

#### Technical Excellence
- **Generic Architecture**: RecordRef-based design supports any table with enum status fields
- **Workflow Integration**: Seamless integration with standard BC workflow engine
- **Code Generation**: Template-driven AL generation with validation and error handling
- **Deployment Automation**: GitHub Actions integration for SaaS and PowerShell for OnPrem

#### Business Value
- **Time Savings**: Eliminates weeks of manual AL development per custom document
- **Consistency**: Standardized approval patterns across all documents
- **Maintainability**: Centralized configuration and automated updates
- **Scalability**: Supports unlimited custom documents and approval scenarios

#### Implementation Focus
- **Practical Examples**: Demonstrated with Test Approval document and reusable for Purchase Requisition, IRN, IGP, OGP
- **Real BC Terminology**: Uses authentic Business Central concepts and patterns
- **Production Ready**: Comprehensive testing, error handling, and monitoring

### How It Works

#### Approval Actions Injection
Generated page extensions inject approval actions into the Processing menu of card pages:
- Actions appear conditionally based on user permissions and record state
- Send/Cancel actions are enabled based on configurable status values
- Approve/Reject actions are visible only when users have open approval entries

#### Workflow Reuse Instead of Rebuild
- Creates workflow templates in standard BC Workflow tables
- Templates can be enabled per company and reused across multiple records
- Leverages standard workflow engine for event handling and response execution
- Supports standard approval routing, notifications, and completion logic

#### Metadata-Driven AL Generation
- Configuration metadata (table ID, status field, page ID) drives code generation
- Templates with placeholders generate complete page extensions
- Generated code includes proper error handling and validation
- Compilation validation ensures deployable code

#### Deployment Handling
- **Internal**: Instant/scheduled deployment via BC APIs and job queues
- **External**: GitHub Actions dispatch for CI/CD pipelines
- **Monitoring**: Real-time status tracking and error reporting
- **Rollback**: Automated rollback for failed deployments

### Practical Examples

#### Test Approval Document
1. Configure table "Approval Testing" with status field and card page
2. Generate page extension with approval actions
3. Create workflow template for approval routing
4. Deploy and test approval workflow

#### Reuse for Purchase Requisition
1. Configure table "Purchase Requisition" with status field
2. Generate page extension for PR card page
3. Reuse existing workflow template or create new one
4. Deploy and enable for PR approval process

#### Scaling to IRN, IGP, OGP
- Same configuration pattern applies to all custom documents
- Workflow templates can be shared across similar document types
- Centralized configuration reduces maintenance overhead
- Consistent user experience across all approval processes

### Quality Assurance
The solution has been designed with production-quality considerations:
- **Comprehensive Documentation**: Suitable for solution architects, functional specifications, technical designs, developer guides, UAT references, and product blueprints
- **Testing Coverage**: UAT and negative test scenarios ensure robustness
- **Error Handling**: Comprehensive error handling and recovery strategies
- **Security**: Permission-based access and audit logging
- **Maintainability**: Modular design with clear separation of concerns

This solution transforms approval workflow implementation from a manual, error-prone process into a streamlined, automated framework that scales with business needs while maintaining the full power and flexibility of Business Central's workflow engine.

---

*End of Document*
