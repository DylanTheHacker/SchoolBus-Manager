using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL
{
    public class DalTableAbsent
    {
        public DalTableAbsent()
        {

        }

        /// <summary>
        /// insert bus info
        /// </summary>
        /// <param name="absentinfo"></param>
        /// <returns></returns>
        public bool insertAbsentInfo(AbsentInfo absentInfo)
        {
            string sql = "insert into absent (absentdate,absentuserid)values(@absentdate,@absentuserid)";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@absentdate", absentInfo.absentdate);
            dict.Add("@absentuserid", absentInfo.absentuserid);
            int count = SqlHelper.ExecuteNonQuery(sql, dict);
            if (count > 0)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        /// <summary>
        /// is record exsit
        /// </summary>
        /// <param name="absentinfo"></param>
        /// <returns></returns>
        public bool isRecordExist(AbsentInfo absentInfo)
        {
            string sql = "select count(*) from absent where absentdate=@absentdate and absentuserid=@absentuserid";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@absentdate", absentInfo.absentdate);
            dict.Add("@absentuserid", absentInfo.absentuserid);
            return SqlHelper.IsExists(sql,dict);
        }

        public bool deleteAbsentInfo(AbsentInfo absentInfo)
        {
            string sql = "delete from absent where absentdate=@absentdate and absentuserid=@absentuserid";
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict.Add("@absentdate", absentInfo.absentdate);
            dict.Add("@absentuserid", absentInfo.absentuserid);
            int count = SqlHelper.ExecuteNonQuery(sql, dict);
            if (count > 0)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }
}
