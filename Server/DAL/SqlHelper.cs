using Npgsql;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL
{
    public static class SqlHelper
    {
        /// <summary>
        /// connect db
        /// </summary>
        /// <returns></returns>
        private static NpgsqlConnection GetConn()
        {
           string connStr = System.Configuration.ConfigurationManager.ConnectionStrings["BusConnection"].ConnectionString;
            return new NpgsqlConnection(connStr);
        }

        /// <summary>
        /// is exist
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="dic"></param>
        /// <returns></returns>
        public static bool IsExists(string sql, Dictionary<string, string> dic)
        {
            bool isExists = false;
            NpgsqlParameter[] ps = new NpgsqlParameter[dic.Count];
            int index = 0;
            foreach (var item in dic)
            {
                ps[index++] = new NpgsqlParameter(item.Key, item.Value);
            }
            using (NpgsqlConnection conn = GetConn())
            {
                NpgsqlCommand cmd = new NpgsqlCommand(sql, conn);
                cmd.CommandType = CommandType.Text;
                cmd.Parameters.AddRange(ps);
                conn.Open();
                int obj = Convert.ToInt32(cmd.ExecuteScalar());
                if (obj > 0)
                {
                    isExists = true;
                }
            }
            return isExists;
        }

        /// <summary>
        /// execute non query
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="dic"></param>
        /// <returns></returns>
        public static int ExecuteNonQuery(string sql, Dictionary<string, string> dic)
        {
            NpgsqlParameter[] ps = new NpgsqlParameter[dic.Count];
            int index = 0;
            foreach (var item in dic)
            {
                ps[index++] = new NpgsqlParameter(item.Key, item.Value);
            }
            return ExecuteNonQuery(sql, CommandType.Text, ps);
        }

        /// <summary>
        /// execute non query
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="type"></param>
        /// <param name="ps"></param>
        /// <returns></returns>
        public static int ExecuteNonQuery(string sql, CommandType type, params NpgsqlParameter[] ps)
        {
            int rows = -1;
            using (NpgsqlConnection conn = GetConn())
            {
                NpgsqlCommand cmd = new NpgsqlCommand(sql, conn);
                cmd.CommandType = type;
                cmd.Parameters.AddRange(ps);
                conn.Open();
                rows = cmd.ExecuteNonQuery();
            }
            return rows;
        }

        /// <summary>
        /// Execute Scalar
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="dic"></param>
        /// <returns></returns>
        public static object ExecuteScalar(string sql, Dictionary<string, string> dic)
        {
            NpgsqlParameter[] ps = new NpgsqlParameter[dic.Count];
            int index = 0;
            foreach (var item in dic)
            {
                ps[index++] = new NpgsqlParameter(item.Key, item.Value);
            }
            return ExecuteScalar(sql, ps);
        }

        /// <summary>
        /// Execute Scalar
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="ps"></param>
        /// <returns></returns>
        public static object ExecuteScalar(string sql, params NpgsqlParameter[] ps)
        {
            Object obj = null;
            using (NpgsqlConnection conn = GetConn())
            {
                NpgsqlCommand cmd = new NpgsqlCommand(sql, conn);
                cmd.Parameters.AddRange(ps);
                conn.Open();
                obj = cmd.ExecuteScalar();
            }
            return obj;
        }

        /// <summary>
        /// Execute Scalar
        /// </summary>
        /// <param name="sql"></param>
        /// <returns></returns>
        public static object ExecuteScalar(string sql)
        {
            Object obj = null;
            using (NpgsqlConnection conn = GetConn())
            {
                NpgsqlCommand cmd = new NpgsqlCommand(sql, conn);
                conn.Open();
                obj = cmd.ExecuteScalar();
            }
            return obj;
        }

        /// <summary>
        /// get data table
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="dic"></param>
        /// <returns></returns>
        public static DataTable GetDataTable(string sql, Dictionary<string, string> dic)
        {
            NpgsqlParameter[] ps = new NpgsqlParameter[dic.Count];
            int index = 0;
            foreach (var item in dic)
            {
                ps[index++] = new NpgsqlParameter(item.Key, item.Value);
            }
            return GetDataTable(sql, ps);
        }

        /// <summary>
        /// get data table
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="ps"></param>
        /// <returns></returns>
        public static DataTable GetDataTable(string sql, params NpgsqlParameter[] ps)
        {
            DataTable dt = new DataTable(); ;
            using (NpgsqlConnection conn = GetConn())
            {
                NpgsqlDataAdapter adapter = new NpgsqlDataAdapter(sql, conn);
                adapter.SelectCommand.Parameters.AddRange(ps);
                conn.Open();
                adapter.Fill(dt);
            }
            return dt;

        }
    }
}
