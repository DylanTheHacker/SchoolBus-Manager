using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DAL;
using Model;

namespace BLL
{
    public class BLLAbsent
    {
        private DalTableAbsent dalTableAbsent;

        public BLLAbsent()
        {
            dalTableAbsent = new DalTableAbsent();
        }

        /// <summary>
        /// insert bus info
        /// </summary>
        /// <param name="absentinfo"></param>
        /// <returns></returns>
        public bool insertAbsentInfo(AbsentInfo absentInfo)
        {
            bool isExist = isRecordExist(absentInfo);
            if (isExist)
            {
                return true;
            }
            return dalTableAbsent.insertAbsentInfo(absentInfo);
        }

        /// <summary>
        /// is record exsit
        /// </summary>
        /// <param name="absentinfo"></param>
        /// <returns></returns>
        public bool isRecordExist(AbsentInfo absentInfo)
        {
            return dalTableAbsent.isRecordExist(absentInfo);
        }

        public bool deleteAbsentInfo(AbsentInfo absentInfo)
        {
            bool isExist = isRecordExist(absentInfo);
            if (!isExist)
            {
                return true;
            }
            return dalTableAbsent.deleteAbsentInfo(absentInfo);
        }
    }
}
