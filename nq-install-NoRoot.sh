#!/bin/bash
#
# NodeQuery Agent Installation Script
#
# @version              1.0.6
# @date                 2014-07-30
# @copyright    (c) 2014 http://nodequery.com
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Set environment
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Prepare output
echo -e "|\n|   Local NodeQuery Installer\n|   ===================\n|"

if [ $# -lt 1 ]
then
        echo -e "|   Usage: bash $0 'token'\n|"
        exit 1
fi

# Check if crontab is installed
if [ ! -n "$(command -v crontab)" ]
then

        # Confirm crontab installation
        echo "Crontab is required and could not be found. Exiting"

        exit 1
fi


# Check if cron is running
if [ -z "$(ps -Al | grep cron | grep -v grep)" ]
then

        # Confirm cron service
        echo "Cron is available but not running. Exiting."

fi

# Attempt to delete previous agent
if [ -f ~/nodequery/nq-agent.sh ]
then
        # Remove agent dir
        rm -Rf ~/nodequery

        # Remove cron entry and user
        (crontab  -l | grep -v "~/nodequery/nq-agent.sh")  | crontab -
fi

# Create agent dir
mkdir ~/nodequery

# Download agent
echo -e "|   Downloading nq-agent.sh to ~/nodequery\n|\n|   + $(wget -nv -o /dev/stdout -O ~/nodequery/nq-agent.sh --no-check-certificate https://raw.github.com/nodequery/nq-agent/master/nq-agent.sh)"

sed -i "s./etc.\~." ~/nodequery/nq-agent.sh

if [ -f ~/nodequery/nq-agent.sh ]
then
        # Create auth file
        echo "$1" > ~/nodequery/nq-auth.log



        # Configure cron
        crontab  -l 2>/dev/null | { cat; echo "*/3 * * * * bash ~/nodequery/nq-agent.sh > ~/nodequery/nq-cron.log 2>&1"; } | crontab -

        # Show success
        echo -e "|\n|   Success: The NodeQuery agent has been installed\n|"

        # Attempt to delete installation script
        if [ -f $0 ]
        then
                rm -f $0
        fi
else
        # Show error
        echo -e "|\n|   Error: The NodeQuery agent could not be installed\n|"
fi
