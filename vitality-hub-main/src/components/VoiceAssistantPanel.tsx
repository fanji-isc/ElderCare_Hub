import { useState } from "react";
import VoiceButton from "@/components/VoiceButton";

type Msg = { role: "user" | "assistant"; content: string };

async function speak(text: string) {
  try {
    const res = await fetch("http://localhost:3001/api/speak", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text }),
    });

    const ct = res.headers.get("content-type") || "";
    if (!res.ok || !ct.startsWith("audio/")) return;

    const blob = await res.blob();
    const url = URL.createObjectURL(blob);
    const audio = new Audio(url);
    audio.onended = () => URL.revokeObjectURL(url);
    await audio.play();
  } catch {
    // silent
  }
}

export default function VoiceAssistantPanel() {
  const [messages, setMessages] = useState<Msg[]>([]);
  const [isThinking, setIsThinking] = useState(false);

  const handleVoice = async (text: string) => {
    const userText = (text || "").trim();
    if (!userText) return;

    const nextMessages: Msg[] = [...messages, { role: "user", content: userText }];
    setMessages(nextMessages);
    setIsThinking(true);

    try {
      const res = await fetch("http://localhost:3001/api/answer", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ text: userText, messages: nextMessages }),
      });

      const data = await res.json();

      const a =
        !res.ok || data?.error
          ? "Sorry — something went wrong."
          : String(data.answer || "").trim();

      setMessages([...nextMessages, { role: "assistant", content: a }]);
      speak(a);
    } catch {
      const errMsg = "Sorry — network error.";
      setMessages([...nextMessages, { role: "assistant", content: errMsg }]);
      speak("I'm having trouble connecting right now.");
    } finally {
      setIsThinking(false);
    }
  };

  return (
    <div className="w-full">
      <VoiceButton onTranscript={handleVoice} />

      {messages.length > 0 && (
        <div className="mt-4 rounded-2xl bg-muted/60 p-5">
          <div className="space-y-3">
            {messages.map((m, i) => (
              <div key={i} className="flex gap-3">
                <div className="shrink-0 font-semibold">
                  {m.role === "user" ? "You" : "Assistant"}
                </div>
                <div>{m.content}</div>
              </div>
            ))}

            {isThinking && messages[messages.length - 1]?.role === "user" && (
              <div className="flex gap-3 text-muted-foreground">
                <div className="shrink-0 font-semibold">Assistant</div>
                <div>Thinking…</div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
