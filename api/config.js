// Vercel 서버리스 함수: Supabase URL/anon key를 소스에 넣지 않고
// Vercel 환경 변수(SUPABASE_URL, SUPABASE_ANON_KEY)에서 읽어 내려준다.
module.exports = (req, res) => {
  if (req.method !== "GET") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }
  res.setHeader("Cache-Control", "no-store");
  res.status(200).json({
    url: process.env.SUPABASE_URL || null,
    anonKey: process.env.SUPABASE_ANON_KEY || null,
  });
};
