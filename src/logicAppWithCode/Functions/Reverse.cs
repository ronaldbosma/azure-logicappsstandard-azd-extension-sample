//------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//------------------------------------------------------------

namespace Functions
{
    using System;
    using System.Collections.Generic;
    using System.Threading.Tasks;
    using Microsoft.Azure.Functions.Extensions.Workflows;
    using Microsoft.Azure.Functions.Worker;
    using Microsoft.Extensions.Logging;

    /// <summary>
    /// Represents the Reverse flow invoked function.
    /// </summary>
    public class Reverse
    {
        private readonly ILogger<Reverse> logger;

        public Reverse(ILoggerFactory loggerFactory)
        {
            logger = loggerFactory.CreateLogger<Reverse>();
        }

        /// <summary>
        /// Reverses a string.
        /// </summary>
        [Function("Reverse")]
        public Task<string> Run([WorkflowActionTrigger] string original)
        {
            this.logger.LogInformation("Starting Reverse with original string: " + original);

            char[] charArray = original.ToCharArray();
            Array.Reverse(charArray);
            string reversed = new string(charArray);

            this.logger.LogInformation("Reversed string: " + reversed);

            return Task.FromResult(reversed);
        }
    }
}
