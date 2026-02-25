import { useEffect, useState } from "react";
import TodoList from "./components/TodoList";
import { getTodos, createTodo, deleteTodo, updateTodo } from "./api/todoApi";
import type { Todo } from "./types/Todo";

export default function App() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [text, setText] = useState("");

  const load = async () => {
    setTodos(await getTodos());
  };

  useEffect(() => { load(); }, []);

  const add = async () => {
    if (!text.trim()) return;
    await createTodo(text);
    setText("");
    load();
  };

  const toggle = async (todo: Todo) => {
    await updateTodo({ ...todo, completed: !todo.completed });
    load();
  };

  const remove = async (id: number) => {
    await deleteTodo(id);
    load();
  };

  return (
    <div style={{ padding: 40 }}>
      <h1>Todo</h1>

      <input
        value={text}
        onChange={e => setText(e.target.value)}
        placeholder="New todo..."
      />
      <button onClick={add}>Add</button>

      <TodoList todos={todos} onToggle={toggle} onDelete={remove} />
    </div>
  );
}