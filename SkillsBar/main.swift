import AppKit

if CommandLine.arguments.contains("--self-test") {
    let block = "---\nname: test-tool\ndescription: >-\n  第一行\n  第二行\nmetadata:\n  name: ignored\n---\n正文"
    let parsed = FrontmatterParser.parse(content: block)!
    precondition(parsed.name == "test-tool" && parsed.description == "第一行 第二行" && parsed.body == "正文")
    let literal = FrontmatterParser.parse(content: "---\nname: test\ndescription: |\n  第一行\n  第二行\n---\n正文")!
    precondition(literal.description == "第一行\n第二行")
    let skill = Skill(name: "workbuddy-credits-manager", description: "", source: .workbuddy, path: "/tmp/workbuddy-credits-manager/SKILL.md")
    precondition(skill.displayName == "工作搭档积分管家" && skill.triggerCommand == "workbuddy-credits-manager")
    precondition(SkillStore.SkillTab.workbuddy.groupID == "workbuddy")
    precondition(SkillsBarLayout.windowWidth == 760)
    // Isolate persistence tests from the real user's categories.
    MainActor.assumeIsolated {
        let suite = "cn.huixin.skillsmanager.tests." + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = SkillStore(workflowDefaults: defaults)
        let sample = Skill(name: "remotion-render", description: "导出成片", source: .codexCLI(.user), path: "/tmp/huixin-fixture/remotion/SKILL.md")
        precondition(store.workflowCategory(for: sample) == .video)
        let office = Skill(name: "spreadsheets", description: "", source: .codexCLI(.user), path: "/tmp/huixin-fixture/spreadsheets/SKILL.md")
        precondition(store.workflowCategory(for: office) == .office)
        let unknown = Skill(name: "xyz-123", description: "", source: .workbuddy, path: "/tmp/huixin-fixture/xyz-123/SKILL.md")
        precondition(store.workflowCategory(for: unknown) == .other)
        store.setWorkflowCategory(.business, for: sample)
        let collection = store.createCollection(named: "产品发布")
        store.toggleWorkflowMembership(sample, in: collection)
        let reopened = SkillStore(workflowDefaults: defaults)
        precondition(reopened.workflowCategory(for: sample) == .business)
        precondition(reopened.collections.count == 1 && reopened.workflowContains(reopened.collections[0], skill: sample))
        reopened.renameCollection(reopened.collections[0], to: "客户项目")
        let renamed = SkillStore(workflowDefaults: defaults)
        precondition(renamed.collections[0].name == "客户项目")
        renamed.toggleWorkflowMembership(sample, in: renamed.collections[0])
        precondition(renamed.collections[0].skillPaths.isEmpty)
        renamed.setWorkflowCategory(nil, for: sample)
        precondition(SkillStore(workflowDefaults: defaults).workflowCategory(for: sample) == .video)
        renamed.deleteCollection(renamed.collections[0])
        precondition(SkillStore(workflowDefaults: defaults).collections.isEmpty)
        // Linked installations refer to one skill for overrides and membership.
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let file = folder.appendingPathComponent("SKILL.md")
        try! "fixture".write(to: file, atomically: true, encoding: .utf8)
        let alias = folder.appendingPathComponent("alias.md")
        try! FileManager.default.createSymbolicLink(at: alias, withDestinationURL: file)
        let real = Skill(name: "sample", description: "", source: .workbuddy, path: file.path)
        let linked = Skill(name: "sample", description: "", source: .pi(.shared), path: alias.path)
        renamed.setWorkflowCategory(.knowledge, for: real)
        precondition(renamed.workflowCategory(for: linked) == .knowledge)
        let sharedCollection = renamed.createCollection(named: "跨来源")
        renamed.toggleWorkflowMembership(real, in: sharedCollection)
        precondition(renamed.workflowContains(renamed.collections[0], skill: linked))
        renamed.toggleWorkflowMembership(linked, in: renamed.collections[0])
        precondition(renamed.collections[0].skillPaths.isEmpty)
    }
    print("通过：多行说明、元数据隔离、中文显示、原始调用名、来源分组、加宽面板、自动分类、手动纠正、自定义分类、重启恢复、跨来源链接")
    exit(0)
}
if CommandLine.arguments.contains("--plugin-catalog-json") {
    let rows = PluginScanner().scanInstalledPlugins().map { ["name": $0.name, "displayName": $0.displayName] }
    FileHandle.standardOutput.write(try! JSONSerialization.data(withJSONObject: rows, options: [.prettyPrinted]))
    exit(0)
}
if CommandLine.arguments.contains("--catalog-json") {
    let skills = SkillScanner().scanAll()
    let rows = skills.map { ["name": $0.name, "displayName": $0.displayName, "description": $0.description, "path": $0.path, "source": $0.source.groupTitle, "trigger": $0.triggerCommand] }
    let data = try! JSONSerialization.data(withJSONObject: rows, options: [.prettyPrinted, .sortedKeys])
    FileHandle.standardOutput.write(data)
    exit(0)
}
let app = NSApplication.shared
let delegate = MainActor.assumeIsolated { AppDelegate() }
app.delegate = delegate
app.run()
