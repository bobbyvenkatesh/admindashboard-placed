import { createClient } from "@/utils/supabase/server";
import { cookies } from "next/headers";

export default async function Page() {
  const cookieStore = await cookies();
  const supabase = createClient(cookieStore);

  const { data: students, error } = await supabase
    .from("admin_students")
    .select("*");

  if (error) {
    console.error("Failed to fetch students:", error.message);
  }

  return (
    <div style={{ minHeight: "100vh", position: "relative", backgroundColor: "#F8FAFC", overflow: "hidden" }}>
      {/* Subtle Logo Watermark Background */}
      <div 
        style={{
          position: "fixed",
          top: "50%",
          left: "50%",
          transform: "translate(-50%, -50%)",
          width: "520px",
          maxWidth: "80vw",
          height: "520px",
          maxHeight: "80vh",
          backgroundImage: "url('/logo.png')",
          backgroundRepeat: "no-repeat",
          backgroundPosition: "center",
          backgroundSize: "contain",
          opacity: 0.038,
          pointerEvents: "none",
          zIndex: 0,
          mixBlendMode: "multiply"
        }}
        aria-hidden="true"
      />
      <main style={{ position: "relative", zIndex: 1, padding: "40px 24px", fontFamily: "system-ui, sans-serif", maxWidth: 880, margin: "0 auto" }}>
        <div style={{ marginBottom: 24 }}>
          <h1 style={{ fontSize: 24, fontWeight: 800, color: "#0F172A", margin: "0 0 6px 0" }}>Placement &amp; Assessment Intelligence</h1>
          <p style={{ color: "#64748B", fontSize: 14, margin: 0 }}>Supabase Live Connected Candidates</p>
        </div>
        <div style={{ background: "#FFFFFF", borderRadius: 16, border: "1px solid #E2E8F0", padding: "24px 28px", boxShadow: "0 1px 3px rgba(15,23,42,0.06)" }}>
          <ul style={{ lineHeight: 2, paddingLeft: 20, margin: 0, color: "#1E293B" }}>
            {students && students.length > 0 ? (
              students.map((student: any) => (
                <li key={student.id}>
                  <strong>{student.name}</strong> — {student.department} ({student.institution}) | Readiness: <span style={{ fontWeight: 700 }}>{student.readiness}%</span> ({student.risk} Risk)
                </li>
              ))
            ) : (
              <li style={{ color: "#64748B" }}>No candidate records found. Use the dashboard to onboard or upload candidates.</li>
            )}
          </ul>
        </div>
      </main>
    </div>
  );
}
