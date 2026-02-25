import type { Todo } from "../types/Todo";

interface Props {
  todos: Todo[];
  onToggle: (todo: Todo) => void;
  onDelete: (id: number) => void;
}

export default function TodoList({ todos, onToggle, onDelete }: Props) {
  return (
    <ul>
      {todos.map(t => (
        <li key={t.id}>
          <span
            onClick={() => onToggle(t)}
            style={{
              cursor: "pointer",
              textDecoration: t.completed ? "line-through" : "none"
            }}
          >
            {t.title}
          </span>

          <button onClick={() => onDelete(t.id)}>❌</button>
        </li>
      ))}
    </ul>
  );
}