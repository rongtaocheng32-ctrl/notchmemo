import SwiftUI
import Combine
import Foundation
import DynamicNotchKit

struct FocusTask: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var isDone = false
}

@MainActor
final class NotchMemoModel: ObservableObject {
    @Published var tasks: [FocusTask] = [] { didSet { save() } }
    @Published var note = "" { didSet { save() } }
    @Published var newTask = ""
    @Published var secondsRemaining = 25 * 60
    @Published var timerRunning = false

    private let storageKey = "notchmemo.state.v1"
    private var ticker: AnyCancellable?

    struct StoredState: Codable {
        var tasks: [FocusTask]
        var note: String
    }

    init() {
        load()
        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in self?.tick() }
            }
    }

    var completedCount: Int { tasks.filter(\.isDone).count }
    var timerText: String { String(format: "%02d:%02d", secondsRemaining / 60, secondsRemaining % 60) }

    func addTask() {
        let title = newTask.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, tasks.count < 3 else { return }
        tasks.append(FocusTask(title: title))
        newTask = ""
    }

    func toggle(_ task: FocusTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isDone.toggle()
        if tasks[index].isDone {
            showNotch(title: "完成一项重点", description: tasks[index].title, icon: "checkmark.circle.fill")
        }
    }

    func remove(_ task: FocusTask) {
        tasks.removeAll { $0.id == task.id }
    }

    func clearCompleted() {
        tasks.removeAll(\.isDone)
    }

    func toggleTimer() { timerRunning.toggle() }

    func resetTimer() {
        timerRunning = false
        secondsRemaining = 25 * 60
    }

    private func tick() {
        guard timerRunning else { return }
        if secondsRemaining > 0 {
            secondsRemaining -= 1
        } else {
            timerRunning = false
            showNotch(title: "专注完成", description: "休息一下，再开始下一轮。", icon: "timer")
        }
    }

    private func showNotch(title: String, description: String, icon: String) {
        Task { @MainActor in
            let notch = DynamicNotchInfo(
                icon: .init(systemName: icon, color: .green),
                title: LocalizedStringKey(title),
                description: LocalizedStringKey(description),
                style: .auto
            )
            await notch.expand()
            try? await Task.sleep(for: .seconds(2))
            await notch.hide()
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(StoredState(tasks: tasks, note: note)) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let state = try? JSONDecoder().decode(StoredState.self, from: data) else { return }
        tasks = state.tasks
        note = state.note
    }
}

struct NotchMemoView: View {
    @ObservedObject var model: NotchMemoModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NotchMemo").font(.largeTitle.bold())
                    Text("把今天最重要的三件事放在眼前")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(model.completedCount)/\(model.tasks.count)")
                    .font(.title2.monospacedDigit().bold())
                    .padding(10)
                    .background(.green.opacity(0.15), in: Circle())
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("今日重点").font(.headline)
                ForEach(model.tasks) { task in
                    HStack {
                        Button { model.toggle(task) } label: {
                            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                        }
                        .buttonStyle(.plain)
                        Text(task.title)
                            .strikethrough(task.isDone)
                            .foregroundStyle(task.isDone ? .secondary : .primary)
                        Spacer()
                        Button(role: .destructive) { model.remove(task) } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(10)
                    .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                }
                if model.tasks.count < 3 {
                    HStack {
                        TextField("例如：完成作品集首页", text: $model.newTask)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { model.addTask() }
                        Button("添加") { model.addTask() }
                            .disabled(model.newTask.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                if model.completedCount > 0 {
                    Button("清理已完成任务", systemImage: "checkmark.circle") {
                        model.clearCompleted()
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("25 分钟专注").font(.headline)
                    Text(model.timerText)
                        .font(.system(size: 34, weight: .semibold, design: .rounded).monospacedDigit())
                    HStack {
                        Button(model.timerRunning ? "暂停" : "开始") { model.toggleTimer() }
                            .buttonStyle(.borderedProminent)
                        Button("重置") { model.resetTimer() }
                    }
                }
                Spacer()
                ZStack {
                    Circle().stroke(.quaternary, lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: CGFloat(25 * 60 - model.secondsRemaining) / CGFloat(25 * 60))
                        .stroke(.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 86, height: 86)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("随手记").font(.headline)
                TextEditor(text: $model.note)
                    .font(.body)
                    .frame(minHeight: 92)
                    .padding(6)
                    .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(24)
        .frame(minWidth: 520, minHeight: 590)
    }
}

@main
struct NotchMemoApp: App {
    @StateObject private var model = NotchMemoModel()

    var body: some Scene {
        WindowGroup {
            NotchMemoView(model: model)
        }
        .windowResizability(.contentSize)

        MenuBarExtra("NotchMemo", systemImage: "checklist") {
            VStack(alignment: .leading, spacing: 8) {
                Text("今日重点").font(.headline)
                if model.tasks.isEmpty {
                    Text("还没有添加任务").foregroundStyle(.secondary)
                } else {
                    ForEach(model.tasks) { task in
                        Button {
                            model.toggle(task)
                        } label: {
                            Label(task.title, systemImage: task.isDone ? "checkmark.circle.fill" : "circle")
                        }
                    }
                }
                Divider()
                Text("专注计时：\(model.timerText)").monospacedDigit()
                Button(model.timerRunning ? "暂停计时" : "开始计时") { model.toggleTimer() }
                Button("退出") { NSApplication.shared.terminate(nil) }
            }
            .padding(8)
        }
    }
}
