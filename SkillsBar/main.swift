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
    print("通过：多行说明、元数据隔离、中文显示、原始调用名、来源分组、加宽面板")
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
