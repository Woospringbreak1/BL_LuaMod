using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LuaMod.LuaAPI
{
    public class BLFileAccess
    {
        protected string relativeFileName;
        protected int currentLineNumber = 0;

        public BLFileAccess(string name)
        {
            relativeFileName = name;
        }

        private static string ResolvePath(string relativePath)
        {
            return (Security.GetRelativePath(relativePath));
        }

        private string ResolvedFilePath => ResolvePath(relativeFileName);

        public bool Write(string contents, bool append)
        {
            return LuaSafeCall.Run(() =>
            {
                string path = ResolvedFilePath;

            if (!Security.IsSafePath(path))
            {
                throw new UnauthorizedAccessException("Attempted to write to an unsafe file path.");
            }

            using (var sw = new StreamWriter(path, append))
            {
                sw.Write(contents);
            }

            return true;
            }, $"BLFileAccess.Write('{contents}')");
        }

        public bool WriteLine(string line, bool append)
        {
            return LuaSafeCall.Run(() =>
            {
                string path = ResolvedFilePath;

                if (!Security.IsSafePath(path))
                {
                    throw new UnauthorizedAccessException("Attempted to write to an unsafe file path.");
                }

                using (var sw = new StreamWriter(path, append))
                {
                    sw.WriteLine(line);
                }

                return true;

            }, $"BLFileAccess.WriteLine('{line}')");
        }

        public string ReadToEnd()
        {
            return LuaSafeCall.Run(() =>
            {
                string path = ResolvedFilePath;

                if (!Security.IsSafePath(path))
                {
                    throw new UnauthorizedAccessException("Attempted to read from an unsafe file path.");
                }

                using (var sr = new StreamReader(path))
                {
                    return sr.ReadToEnd();
                }
            }, $"BLFileAccess.ReadToEnd()')");
        }

        public string ReadLine()
        {
            return LuaSafeCall.Run(() =>
            {
                string path = ResolvedFilePath;

                if (!Security.IsSafePath(path))
                {
                    throw new UnauthorizedAccessException("Attempted to read from an unsafe file path.");
                }

                using (var sr = new StreamReader(path))
                {
                    for (int i = 0; i < currentLineNumber; i++)
                    {
                        if (sr.ReadLine() == null)
                            return null; // Early EOF
                    }

                    string line = sr.ReadLine();
                    if (line != null)
                        currentLineNumber++;

                    return line;
                }
            }, $"BLFileAccess.ReadLine()')");
        }

        public int LineNumber
        {
                get => currentLineNumber;
                set
                {
                    if (value < 0)
                        currentLineNumber = 0;
                    else
                        currentLineNumber = SeekToLine(value);
                }
        }

        private int SeekToLine(int targetLine)
        {
            string path = ResolvedFilePath;

            if (!Security.IsSafePath(path))
            {
                throw new UnauthorizedAccessException("Attempted to read from an unsafe file path.");
            }

            try
            {
                using (var sr = new StreamReader(path))
                {
                    int line = 0;
                    while (line < targetLine && sr.ReadLine() != null)
                        line++;

                    return line;
                }
            }
            catch
            {
                return 0;
            }
        }

        public void Close()
        {
            // No streams held persistently — just reset state
            currentLineNumber = 0;
        }
    }
}
